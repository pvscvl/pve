# Preparations for root-ssh login

## As Pi User
> `mkdir /home/pi/.ssh`
> 
> `chmod 700 /home/pi/.ssh`
> 
> `echo ssh-rsa AAxsd user@host  >> /home/pi/.ssh/authorized_keys2`
> 
> `chmod 600 /home/pi/.ssh/authorized_keys2`



## As Root User
> `mkdir /root/.ssh`
> 
> `chmod 700 /root/.ssh`
> 
>  ` echo ssh-rsa AAxsd user@host  >> /root/.ssh/authorized_keys2 `
>  
>  `chmod 600 /root/.ssh/authorized_keys2`



## Configure sshd_config for root login
> `sudo sed -i "/#PermitRootLogin prohibit-password/ s//PermitRootLogin yes/g" /etc/ssh/sshd_config`
> 
> `sudo sed -i "/#PubkeyAuthentication yes/ s//PubkeyAuthentication yes/g" /etc/ssh/sshd_config`
> 
> `sudo sed -i "/#AuthorizedKeysFile/ s//AuthorizedKeysFile/g" /etc/ssh/sshd_config`

## Prep 
>  `apt install qemu-guest-agent `
>  
>  `apt install --install-recommends linux-virtual `
> 
>  `apt install linux-tools-virtual linux-cloud-tools-virtual `
> 
>  `sed -i 'GRUB_CMDLINE_LINUX_DEFAULT="/ s//GRUB_CMDLINE_LINUX_DEFAULT="elevator=noop"/g' /etc/default/grub `
> 
>  `nano /etc/default/grub `
>  
>  `GRUB_CMDLINE_LINUX_DEFAULT="elevator=noop" `
> 
>  `update-grub` 
> 
> `reboot `

