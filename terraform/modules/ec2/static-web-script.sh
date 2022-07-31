#!/bin/bash

# Get updates and install tomcat
yum update -y
yum install -y tomcat

# Change default port
sed -i 's/8080/80/g' /etc/tomcat/server.xml

# Enable net binding
TOMCAT_SERVICE_PATH=$(sudo systemctl cat tomcat | head -1 | sed 's+# ++')
sed -i 's+\[Service]+\[Service]\nAmbientCapabilities=CAP_NET_BIND_SERVICE+' $TOMCAT_SERVICE_PATH

# Fetch required instance details
INSTANCE_ID=$(ec2-metadata -i | sed 's/instance-id: //')
IP_ADDR=$(ec2-metadata -v | sed 's/public-ipv4: //')
MAC_ADDR=$(cat /sys/class/net/eth0/address)

TOMCAT_APP_PATH=$(echo '/var/lib/tomcat/webapps')

# Home page for tomcat app
mkdir $TOMCAT_APP_PATH/ROOT && tee $TOMCAT_APP_PATH/ROOT/index.html <<EOF
<!DOCTYPE html>
<html>

<head>
    <style>
        body {
            background-color: beige;
        }

        h1 {
            font-family: Arial;
            color: black;
            border-style: double;
            border-radius: 10px;
            border-width: 5px;
            border-left-width: 15px;
            border-right-width: 15px;
            border-left-color: tan;
            border-right-color: tan;
            border-top-color: gray;
            border-bottom-color: gray;
            padding: 10px;
            inline-size: 500px;
        }

        table {
            font-family: arial, sans-serif;
            border-collapse: collapse;
            width: 35%;
            font-size: 20px;
        }

        td {
            border: 2px solid #dddddd;
            text-align: left;
            padding: 8px;
            size: 10px;
        }

        tr:nth-child(odd) {
            background-color: #dddddd;
        }
    </style>
</head>

<body>
    <center>
        <h1>Instance Details : </h1>
        <table>
            <tr>
                <td style="width: 50%;">&#128187 Instance ID:</td>
                <td>$INSTANCE_ID</td>
            </tr>
            <tr>
                <td>&#127760 IP Address: </td>
                <td>$IP_ADDR</td>
            </tr>
            <tr>
                <td>&#127995 MAC Address: </td>
                <td>$MAC_ADDR</td>
            </tr>

        </table>
    </center>
</body>

</html>
EOF

# Restart the service
systemctl daemon-reload
systemctl stop tomcat
systemctl start tomcat