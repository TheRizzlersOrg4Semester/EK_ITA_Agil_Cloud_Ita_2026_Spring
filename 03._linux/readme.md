# Linux OS
I dag skal i have installeret Linux så i kan lege med operativsystemet.

## Learning Goals
* Installere Linux gennem Docker på din computer.
* Bruge Linux OS gennem dens terminal.
* Få et praktisk overblik over de hyppigst brugte shell kommandoer.
* Forstå Linux´s fil og mappestruktur.
* Kunne installere applikationer i dit linux system.
* Forstå hvad en package manager er og gør.
* Kunne bruge en terminal baseret texteditor (nano)
* Kunne eksevere applikationer (python) på din linux computer.

## Before Class

Se og følg tutorials i de tre videoer:

* [Linux for Hackers // EP 1](https://www.youtube.com/watch?v=VbEx7B_PTOE&list=PLIhvC56v63IJIujb5cyE13oLuyORZpdkL) (11:32)
* [the Linux File System explained in 1,233 seconds // Linux for Hackers // EP 2](https://www.youtube.com/watch?v=A3G-3hp88mo&list=PLIhvC56v63IJIujb5cyE13oLuyORZpdkL&index=2) (20:32)
* [HELP!! (for when you suck at Linux) // Linux for Hackers // EP3](https://www.youtube.com/watch?v=Y17KTiJLcyQ&list=PLIhvC56v63IJIujb5cyE13oLuyORZpdkL&index=3) (13:13)

## Today's Teachings
Vi starter dagen med at kigge på OpennAPI specifikationerne fra sidst og ser hvor langt i er kommer med jeres applikationer.    
Vi kigger også på jeres Kanban Board og snakker om hvordan i skal bruge den.  

Efter dette arbejder vi med Linux resten af dagen og på fredag.       

I skal have installeret Linux så i kan arbejde med operativsystemet.

Det gør i ved at køre denne docker kommando i jeres terminal. (Terminal til Mac, Powershell til Windown)

`docker run -d --name=webtop-ubuntu-mate --security-opt seccomp=unconfined  -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC -e SUBFOLDER=/  -e TITLE=ITADevOps -p 3000:3000 -p 3001:3001 -v ~/webtop:/config -v /var/run/docker.sock:/var/run/docker.sock  --shm-size="1gb"  --restart unless-stopped lscr.io/linuxserver/webtop:ubuntu-mate` 

Herefter kommer i til at arbejde  med systemet og i kommer blandt andet igennem at bruge disse kommandoer: [Linux terminal commands and file system](unix_commands.md)

## After Class

Lav øvelserne: 

* Øvelse: [Unix Command Exercises](unix_commands_exercises.md)
* Øvelse: Kør din gruppes CookBook applikation på din linux computer
    * Du kan køre docker containere på din Linux installation, da den allere kører i et docker image. 
    * Men du kan godt køre din applikation lokalt på denne installation, så bare hop ud i det.
 
Hvis du skulle blive færdig før timen er overstået skal du blive ved med at lege med systemet indtil du rammer en time!

