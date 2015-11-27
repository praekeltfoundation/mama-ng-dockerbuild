for image in $(cat $INSTALLDIR/mama-ng-dockerbuild/images.txt); do
    docker pull $image
done
