sh-check
========

sh-check is a shell script that allows to build scripts doing some checks on a UNIX system.

Basic usage
-----------

```sh
#!/bin/sh

SHCHECK_NB_CHECKS=2

. ./shcheck.sh

shcheck 'Checking if curl is available' shcheck_command_available curl
shcheck 'Checking is /tmp is writable' shcheck_folder_writable /tmp
```

Sample output:

```
$ ./yourscript.sh
[1/2] Checking if curl is available...                                [FAIL]
[2/2] Checking is /tmp is writable...                                 [ OK ]
```

Advanced usage
-----------

```sh
#!/bin/sh

SHCHECK_NB_CHECKS=4

. ./shcheck.sh

check_enough_space() {
  AVAILABLE_SPACE=$(df -BM "$1" | tail -n 1 | awk '{ print $4 }' | sed 's/M//')

  if [ "$AVAILABLE_SPACE" -ge $(($2 * 2)) ]; then
    return 0
  elif [ "$AVAILABLE_SPACE" -ge $2 ]; then
    echo "There is only $AVAILABLE_SPACE Mio left in $1"
    return 255
  else
    return 1
  fi
}

shcheck 'Checking if wget is available' shcheck_command_available wget
shcheck 'Checking if curl is available' shcheck_command_available curls
shcheck 'Checking if there is enough space (700 Mio) in /usr/bin' check_enough_space /usr/bin 700
shcheck 'Checking is /tmp is writable' shcheck_folder_writable /tmp
```

Sample output:

```
$ ./yourscript.sh
[1/4] Checking if wget is available...                                [ OK ]
[2/4] Checking if curl is available...                                [FAIL]
[3/4] Checking if there is enough space (700 Mio) in /usr/bin...      [WARN]
There is only 830 Mio left in /usr/bin
[4/4] Checking is /tmp is writable...                                 [ OK ]
```
