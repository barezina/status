#!/usr/bin/env bash

shopt -s expand_aliases
alias normaltext='tput sgr 0';
alias yellowtext='tput setaf 3';
alias greentext='tput setaf 2';
alias redtext='tput setaf 1';
alias boldtext='tput bold';

now_timestamp="$(date +%s)"

echo "";
boldtext;
echo "★  Status System Installer v1.0 ★";
echo "";
normaltext;

yellowtext;
echo -n "- Current user                             ";
username="$USER";
greentext;
echo "$username";

yellowtext;
echo -n "- Current user id                          ";
userid="$(id -u)";
greentext;
echo "$userid";

# Check for an existing installation

yellowtext;
echo -n "- Checking for .env file                   ";

EXISTING_ENV_FILE=.env;

if [[ -f "$EXISTING_ENV_FILE" ]]
then
    redtext;
    echo "present";
    echo "";
    echo "  An .env file exists at the current location. This may indicate the presence of"
    echo "  an existing application. ";
    echo "";
    echo "  Do you want to remove the existing application, its configuration and ";
    echo "  all of it's containers? (This should only be done in development environments.)";
    echo "";
    echo "  To delete all containers and configuration at this location, type 'delete' (no quotes):";
    echo "";
    echo -n "  Command: ";
    read should_delete_environment;

    if [[ $should_delete_environment == "delete" ]]
    then
        echo;
        echo -n "- Removing previous environment...         ";
        docker-compose down &>> /dev/null;
        rm -rf .env &>> /dev/null;
        rm -rf api/.env &>> /dev/null;
        rm -rf ui/config.js &>> /dev/null;
        rm -rf api/vendor &>> /dev/null;
        rm -rf api/composer.lock &>> /dev/null;
        rm -rf install.log &>> /dev/null;
        greentext;
        echo "done";
        echo;
    else
        echo "  Stopping installation.";
        echo "";
        exit 0;
    fi

else
    greentext;
    echo "not present";
fi

echo "";
yellowtext;
echo -n "- api url (with protocol, no slashes):     ";
greentext;
read api_url;

while [[ $api_port_good != 1 ]]
do
    yellowtext;
    echo -n "  Listening port for api:                  ";
    greentext;
    read api_port;
    yellowtext;
    echo -n "  Checking that port is free:              ";
    greentext;
    nc -vz 127.0.0.1 $api_port &>> /dev/null;
    api_port_result=$?;

    if [[ $api_port_result == 0 ]]; then
        redtext;
        echo "$api_port is occupied";

    else
        greentext;
        echo "✔ free";
        api_port_good=1;
    fi

done

echo "";

while [[ $frontend_port_good != 1 ]]
do
    yellowtext;
    echo -n "  Listening port for frontend:             ";
    greentext;
    read frontend_port;
    yellowtext;
    echo -n "  Checking that port is free:              ";
    greentext;
    nc -vz 127.0.0.1 $frontend_port &>> /dev/null;
    frontend_port_result=$?;

    if [[ $frontend_port_result == 0 ]]; then
        redtext;
        echo "$frontend_port is occupied";

    else
        greentext;
        echo "✔ free";
        frontend_port_good=1;
    fi

done

echo "";

while [[ $mysql_port_good != 1 ]]
do
    yellowtext;
    echo -n "  Listening port for mysql:                ";
    greentext;
    read mysql_port;
    yellowtext;
    echo -n "  Checking that port is free:              ";
    greentext;
    nc -vz 127.0.0.1 $mysql_port &>> /dev/null;
    mysql_port_result=$?;

    if [[ $mysql_port_result == 0 ]]; then
        redtext;
        echo "$mysql_port is occupied";

    else
        greentext;
        echo "✔ free";
        mysql_port_good=1;
    fi

done

echo "";

yellowtext;
echo -n "- Creating .env file                                         ";

touch .env

echo "generation_timestamp=$now_timestamp" >> .env;
echo "username=$username" >> .env;
echo "user_id=$userid" >> .env;
echo "api_path=$api_url:$api_port" >> .env;
echo "api_port=$api_port" >> .env;
echo "frontend_port=$frontend_port" >> .env;
echo "mysql_port=$mysql_port" >> .env;

greentext;
echo "done";

yellowtext;
echo -n "- Creating api .env file                                     ";

cp api/.env.example api/.env;

greentext;
echo "done";

yellowtext;
echo -n "- Creating frontend .env file                                ";

touch ui/config.js;
echo "var status_api_url = \"$api_url:$api_port\"" >> ui/config.js;

greentext;
echo "done";

yellowtext;
echo -n "- Bringing the stack up                                      ";

docker-compose up --build -d &>> install.log;

greentext;
echo "done";

yellowtext;
echo -n "- Installing composer packages                               ";

docker exec status-php-api-$now_timestamp composer install &>> install.log;

greentext;
echo "done";

yellowtext;
echo -n "- Setting laravel app key                                    ";

docker exec status-php-api-$now_timestamp php artisan key:generate &>> install.log;

greentext;
echo "done";

yellowtext;
echo -n "- Migrating the DB                                           ";

docker exec status-php-api-$now_timestamp php artisan migrate &>> install.log;

greentext;
echo "";
echo "";
echo "";
echo "Everything done woooooooooooooooooo! Have fun!";
echo "";
echo "";
echo "";
