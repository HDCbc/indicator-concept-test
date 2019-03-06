#!/bin/bash

ip="66.70.138.146"


socket=$(mktemp -t deploy-ssh-socket.XXX)
rm -f ${socket} # delete socket file so path can be used by ssh

exit_code=0

#----------------------------------------------------------------------
# Create a temp script to echo the SSH password, used by SSH_ASKPASS
#----------------------------------------------------------------------
 
SSH_ASKPASS_SCRIPT=/tmp/ssh-askpass-script
cat > ${SSH_ASKPASS_SCRIPT} <<EOL
#!/bin/bash
echo "${PASS}"
EOL
chmod u+x ${SSH_ASKPASS_SCRIPT}

#----------------------------------------------------------------------
# Set up other items needed for OpenSSH to work.
#----------------------------------------------------------------------
 
# Set no display, necessary for ssh to play nice with setsid and SSH_ASKPASS.
export DISPLAY=:0
 
# Tell SSH to read in the output of the provided script as the password.
# We still have to use setsid to eliminate access to a terminal and thus avoid
# it ignoring this and asking for a password.
export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}
 
# LogLevel error is to suppress the hosts warning. The others are
# necessary if working with development servers with self-signed
# certificates.
SSH_OPTIONS="-oLogLevel=error"
SSH_OPTIONS="${SSH_OPTIONS} -oStrictHostKeyChecking=no"
SSH_OPTIONS="${SSH_OPTIONS} -oUserKnownHostsFile=/dev/null"

cleanup () {
    # Stop SSH port forwarding process, this function may be
    # called twice, so only terminate port forwarding if the
    # socket still exists
    if [ -S ${socket} ]; then
        echo
        echo "Sending exit signal to SSH process"
        ssh -S ${socket} -O exit root@${ip}
    fi
    exit $exit_code
}

trap cleanup EXIT ERR INT TERM


# Start SSH port forwarding process for postgres (39243:5432) 
ssh ${SSH_OPTIONS} -M -S ${socket} -fNT -L 39243:localhost:5432 degli@${ip}
ssh ${SSH_OPTIONS} -S ${socket} -O check root@${ip}

# launching a shell here causes the script to not exit and allows you
# to keep the forwarding running for as long as you want.


psql -v ON_ERROR_STOP=1 -p 39243 -d central -U postgres -h localhost -c "INSERT INTO endpoint_update(id, effective_date, statement, signature) VALUES ((SELECT Max(id) + 1 FROM endpoint_update), CURRENT_TIMESTAMP, null, null);"


# Log in to the remote server and run the above command.
# The use of setsid is a part of the machinations to stop ssh
# prompting for a password.
# setsid ssh ${SSH_OPTIONS} ${USER}@${SERVER} "${CMD}"
