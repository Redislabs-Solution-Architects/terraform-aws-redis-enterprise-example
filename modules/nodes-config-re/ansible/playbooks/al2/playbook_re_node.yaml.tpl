---
- hosts: all
  become: yes
  become_user: root
  become_method: sudo
  gather_facts: yes

#  pre_tasks:

#    - name: Update Package Cache
#      dnf:
#        name: '*'
#        state: latest
#        update_cache: yes
#        use_backend: yum

#    - name: Install packages
#      dnf:
#        state: present
#        name
#          - jq
#          - tree
#          - sysstat
#          - iputils
#          - libcap
#          - gcc
#          - gcc-c++
#          - autoconf
#          - automake
#          - libbsd
#          - libtool
#          - pcre
#          - libevent
#          - pkgconfig
#          - zlib-devel
#          - openssl-devel
#          - ntp

  tasks:
    - name: Create re home dir
      file:
        state: directory
        path: "/redis"

    - name: Create download directory
      file:
        state: directory
        path: "/var/tmp/re-download"

    - name: Unarchive software
      unarchive: 
        src: ${re_download_url}
        dest: /var/tmp/re-download
        remote_src: yes

    - name: Install the software
      command: "./install.sh -y"
      args:
        chdir: /var/tmp/re-download
        creates: /var/opt/redislabs/log/rlcheck.log
