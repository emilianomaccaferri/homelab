# misc/tunnel
tunnels are very simple and intuitive: i see no reason for an us-based company such as cloudflare to ssl-terminate traffic coming to my house with [their stuff](https://www.cloudflare.com/en-gb/products/tunnel/).
<br>
what i decided to do instead is to create a very simple ssh reverse-tunnel that binds to a local port on a VPS and then redirects traffic to my home network.

# the trick
through the `ssh` command, it's possible to create a so-called **reverse tunnel**: basically i can establish a ssh connection between a local machine in my network and a VPS with a public IP, then, forward all traffic i want on such connection; this way i can SSL-terminate traffic on my VPS and then use the ssh connection to route traffic from my vps to my homelab, with the additional benefit of encryption provided by ssh!

![homelab tunnel](/assets/homelab-tunnel.png)

# how
first of all, you'll need to initiate the actual ssh tunnel, which is as simple as running this command on a machine on your local network:

```bash
ssh -N -R remote-port:localhost:local-port user@vps-ip [-i ssh-key]
```
- `-N` stands for "no command", meaning that no shell will be started with this ssh session;
- `-R` specifies that connections to the given TCP port  on the remote host are to be forwarded to the local side.

in otther words, every connection made on `vps-ip:remote-port` are to be forwarded to the local machine on the specified `local-port`.

### adding nginx
to fully extend the power of this solution, we can tell nginx to forward traffic coming towards a certain domain to the `remote-port`, effectively routing http traffic towards our network! this way, we can also leverage `letsencrypt` to issue a certificate!

```nginx
server {                                                                                                                                          
        server_name macca.casa;                                                                                                                   
                                                                                                                                                  
        location ~ /.well-known{                                                                                                                  
                                                                                                                                                  
                root /usr/share/nginx/html;                                                                                                       
                allow all;                                                                                                                        
                                                                                                                                                  
         }
         location / {
                proxy_pass http://127.0.0.1:remote-port/; # remote-port is the same remote port we used in the ssh-tunnel
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $remote_addr;
                proxy_cache_bypass $http_upgrade;
            }


    listen 443 ssl http2; # managed by Certbot
    ssl_certificate ... ## managed by Certbot
    ssl_certificate_key ... # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot 
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
```

very cool! 