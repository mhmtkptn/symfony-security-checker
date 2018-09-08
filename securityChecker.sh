#!/bin/bash

#==============================================================================

#TITLE:            securityCheck.sh
#DESCRIPTION:      Symfony console'u kullanarak composer ile kullanılan paketlerin guvenlik kontrollerini yapar
#AUTHOR:           mhmtkptn
#CRON:             0 2 * * * /bin/bash /script-path/securityChecker.sh >/dev/null 2>&1

#==============================================================================

set -o errexit

readonly scriptName="$(basename "$0")"
readonly baseDir="$(/usr/bin/dirname "$0")"

readonly projectPath=''
readonly composerLockPath=''
readonly logFilePath='/tmp/symfonySecurityCheck.log'

readonly isSendEmail=true
readonly receiverEmailAddress=''
readonly eMailSubject=''


function run () {

    echo -e "Security Check Process Started - $(date +%d.%m.%Y) \n" >> "$logFilePath"

    checkPrivilage
    securityCheck
}

function checkPrivilage () {

    if [ ! -x "$baseDir"/"$scriptName" ]; then
        echo -e "Lutfen root olarak scripti çalıştırın !!! \n Security Check Process ended" >> "$logFilePath"
        exit 1
    fi
}

function securityCheck () {

    php "$projectPath"/bin/console security:check "$composerLockPath" >> "$logFilePath"

    isInFile=$(cat "$logFilePath" | grep -c "No packages have known vulnerabilities")

    if [ "$isInFile" -eq 0 ]; then
        sendEmail
    fi
}

function sendEmail () {

    if [ "$isSendEmail" = false ]; then
        echo -e "\nSecurity Check Process ended" >> "$logFilePath"
        exit 0
    fi

    echo "$(cat "$logFilePath")" | mail -s "$eMailSubject" "$receiverEmailAddress"
}

run
