# mama-ng-dockerbuild
Scripts to build Docker images for the components of MAMA Nigeria

## Build process
```
                                    +----------------------------------------+   +-------------------------------+
                                    |                                        |   |                               |
                                    | praekeltfoundation/mama-ng-dockerbuild |   | praekelt/mama-ng-dockerconfig |
                                    |             Github (public)            |   |        Github (private)       |
                                    |                                        |   |                               |
+-------------------------------+   +-------------------+--------------------+   +--------------+----------------+
|                               |                       |                                       |
| praekelt/mama-ng-contentstore +----+                  | git clone                             |
|                               |    |                  |                                       |
+-------------------------------+    |           /------v-----\                                 |
                                     |  git pull |            |   pip wheel                     |
  +--------------------------+       +-----------> Sideloader |                                 | git clone
  |                          |       |           |            |  docker build                   |
  | praekelt/mama-ng-control +-------+           \------+-----/                                 |
  |                          |       |                  |                                       |
  +--------------------------+       |                  | docker push                           |
                                     |                  |                                       |
 +----------------------------+      |        +---------v----------+                      /-----+------\
 |                            |      |        |                    |     docker pull      |            |
 | praekelt/mama-ng-scheduler +------+        |    qa-mesos-mama   +---------------------->            |
 |                            |               | Docker Registry v2 |                      | Sideloader |  docker build
 +----------------------------+               |                    |          +----------->            |
                                              +--------------------+          |           |            |
                                                                              |           \-----+------/
                                                                              | git pull        |
                                            +------------------------+        |                 |
                                            |                        |        |                 | docker push
                                            | praekelt/mama-ng-jsbox +--------+                 |
                                            |                        |                          |
                                            +------------------------+                +---------v----------+
                                                                                      |                    |
                                                                                      |    qa-mesos-mama   |
                                                                                      | Docker Registry v2 |
                                                                                      |                    |
                                                                                      +--------------------+
```

