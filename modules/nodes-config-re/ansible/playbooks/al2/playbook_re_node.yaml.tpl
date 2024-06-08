---

- hosts: all
  become: yes
  become_user: root
  become_method: sudo
  gather_facts: yes


  pre_tasks:
  - name: Update YUM Cache
    yum:
      update_cache: yes
      
  - name: Upgrade all packages
    yum:
      name: "*"
      state: latest

  - name: Load vars
    include_vars: "{{ item }}"
    with_first_found:
      - "{{ ansible_hostname }}.yaml"
      - "default.yaml"

  - name: Update YUM Cache
    yum:
      name: '*'
      state: latest
      update_cache: yes

  - name: Amazon Linux 2 Packages
    package:
      name: "{{ yum_packages }}"
      state: present


  - name: create re home dir
    file:
      state: directory
      path: "/redis"

  tasks:
    - name: create download directory
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