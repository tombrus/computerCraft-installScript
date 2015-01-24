#!/bin/bash -eu

### the versions that should be used:
mcVersion=1.7.10
frVersion=10.13.2.1230
ccVersion=1.65

### the default port:
port=11111

### the jars, constructed from the version numbers:
mcJar=minecraft_server.$mcVersion.jar
frJar=forge-$mcVersion-$frVersion-installer.jar
ccJar=ComputerCraft$ccVersion.jar

### the download sites for the jars (might change with version):
mcDown="https://s3.amazonaws.com/Minecraft.Download/versions/$mcVersion/$mcJar"
frDown="http://files.minecraftforge.net/maven/net/minecraftforge/forge/$mcVersion-$frVersion/$frJar"
ccDown="http://addons.cursecdn.com/files/2216/236/$ccJar"

### the temp dirs to use:
downloadDir="tmp-downloads"
logDir="tmp-logs"

freshDownload=
onlyClean=
leaveStuff=
while [ $#  != 0 ]; do
    case "$1" in
    -p) shift
        port=$1
        shift
        ;;
    -d) freshDownload=1
        shift
        ;;
    -c) onlyClean=1
        shift
        ;;
    -l) leaveStuff=1
        shift
        ;;
    *)  echo
        echo "     -p <port> the port number that the server should use"
        echo "     -d        delete cached downloads first"
        echo "     -c        clean only, no install"
        echo "     -l        leave downloads and logs after install"
        echo
        exit
    esac
done
installDir="server-$port"

if [ $freshDownload ]; then
    echo "==================== cleaning downloads..."
    rm -rf $downloadDir
fi
echo "==================== cleaning..."
rm -rf $installDir
rm -rf $logDir

if [ $onlyClean ]; then
    exit
fi
mkdir -p $downloadDir
mkdir -p $installDir
mkdir -p $logDir

echo "==================== downloading..."
if [ ! -f $downloadDir/$mcJar ]; then
    wget -O $downloadDir/$mcJar "$mcDown" 2>> $logDir/wget.log
fi
if [ ! -f $downloadDir/$frJar ]; then
    wget -O $downloadDir/$frJar "$frDown" 2>> $logDir/wget.log
fi
if [ ! -f $downloadDir/$ccJar ]; then
    wget -O $downloadDir/$ccJar "$ccDown" 2>> $logDir/wget.log
fi

waitAndKill() {
    text="$1"
    file="$2"
    pid="$3"
    while true; do
        sleep 1
        if [ -f "$file" ] && fgrep -q "$text" "$file"; then
            break;
        fi
    done
    kill $pid
    wait
}

(
    echo "==================== install minecraft..."
    cd $installDir
    cp ../$downloadDir/$mcJar .
    echo "eula=true" > eula.txt
    for f in banned-players.json banned-ips.json ops.json whitelist.json; do 
        touch $f
    done
    cat > server.properties <<EOF
generator-settings=
op-permission-level=4
allow-nether=true
level-name=world
enable-query=false
allow-flight=false
announce-player-achievements=true
server-port=$port
level-type=DEFAULT
enable-rcon=false
level-seed=
force-gamemode=false
server-ip=
max-build-height=256
spawn-npcs=true
white-list=false
spawn-animals=true
hardcore=false
snooper-enabled=true
online-mode=true
resource-pack=
pvp=true
difficulty=1
enable-command-block=false
gamemode=1
player-idle-timeout=0
max-players=20
spawn-monsters=true
generate-structures=true
view-distance=10
motd=Toms test computercraft server
EOF

    echo "==================== initial start of minecraft..."
    java -jar "$mcJar" >../$logDir/minecraft-first-run.log 2>&1 &
    waitAndKill " [Server thread/INFO]: Done " logs/latest.log $!

    echo "==================== install forge..."
    java -jar ../$downloadDir/$frJar --installServer >../$logDir/forge-install.log 2>&1

    echo "==================== initial start of forge..."
    java -jar ${frJar/installer/universal} > ../$logDir/forge-first-run.log 2>&1 &
    waitAndKill " [Server thread/INFO]: Done " logs/latest.log $!

    echo "==================== install computerCraft..."
    mkdir -p mods
    cp ../$downloadDir/$ccJar mods

    echo "==================== running final version..."
    nohup java -jar ${frJar/installer/universal} &
)

if [ ! $leaveStuff ]; then
    rm -rf $logDir $downloadDir
fi
