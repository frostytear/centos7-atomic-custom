# Building and Deploying a Custom CentOS 7 Atomic Host

## What is this?

This README provides steps on building a custom CentOS 7 Atomic Host. 

The default config files in this repo will create a CentOS 7 Atomic Host but with `open-vm-tools` installed for Atomic Host deployment on VMware (and to be able to easily launch new VMs with a tool like [ezmomi](https://github.com/imsweb/ezmomi)). That said, you can easily customize the packages you want installed (See **Customizing** below).

## Step 1: Build 

Build and run a docker container that you'll use to create and serve your custom Atomic Host image:

```
git clone https://github.com/imsweb/centos7-atomic-custom.git
cd centos7-atomic-custom
docker build --rm -t $USER/atomicrepo .
docker run --privileged -d -p 8000:8000 --name atomicrepo $USER/atomicrepo

# Enter the docker container and build the custom Atomic image:
docker exec -it atomicrepo bash
cd sig-atomic-buildscripts
curl http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
rpm-ostree compose tree --repo=/srv/rpm-ostree/repo ./centos-atomic-host-custom.json
```

The `rpm-ostree compose tree` step takes awhile. Once completed, your custom images will be served in a `rpm-ostree` repository at http://mydockerhost.example.com:8000. Your Atomic Hosts can then retrieve images from that URL, per the next step.

## Step 2: Deploy

On an existing CentOS 7 Atomic Host, add your repo and pull down the latest image you've built, and reboot the Atomic host:

```
ostree remote add myrepo http://mydockerhost.example.com:8000 --no-gpg-verify

# pull down image and rebase
rpm-ostree rebase myrepo:centos-atomic-host/7/x86_64/standard

# boot into our new image
systemctl reboot
```

The new image should be the default entry in your boot menu as `(ostree:0)`.

## Deploying updates

New image updates can be applied to existing Atomic hosts like so:

```
atomic host upgrade
# then boot into new image
systemctl reboot
```

## Customizing

Packages you want installed in the Atomic image can be changed in `centos-atomic-host-custom.json`:

```
{
 "include": "centos-atomic-host.json",
 "packages": ["open-vm-tools"],
 "units": ["vmtoolsd"]
}
```

Here we are including the default `.json` file that builds a vanilla CentOS Atomic Host. The `units` entry specifies what service should be enabled on boot.
