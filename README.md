## nmap_docker_image
- Full featured NMAP implementation. 
- Lean and up-to-date.
- CI/CD built, monitored and maintained.
- Compiled fresh from latest stable source: 
 https://nmap.org/dist/nmap-7.92.tgz
- Clean, scratch-built image.
- Single concern container.


#### Run as you would native nmap, just add the `docker run` prefix.
``` 
docker run motornyuk/nmap 
```
###### An alias can be added for the nmap command: `alias nmap="docker run motornyuk/nmap"`
###### Add to "$HOME/.bashrc" to make alias permanent.

#### Example Commands:
 - docker run motornyuk/nmap -V
 - docker run motornyuk/nmap -v -Pn -sS -T2 --top-ports 50 scanme.nmap.org
 - docker run motornyuk/nmap -vv -Pn -sT -T3 --top-ports 500 scanme.nmap.org 
 - docker run motornyuk/nmap -vvv -Pn -sU -T4 --top-ports 1000 scanme.nmap.org 
 - docker run motornyuk/nmap -v -A scanme.nmap.org 

