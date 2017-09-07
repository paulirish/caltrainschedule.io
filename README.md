# [caltrainschedule.io](https://caltrainschedule.io/)

Service worker enabled for offline and add to homescreen excellence.

![image](https://cloud.githubusercontent.com/assets/39191/15494867/a3f2a7c2-2141-11e6-9793-9b38e03aa6cf.png)

This is a @samccone & @paulirish collab. Also probably [other awesome people](https://github.com/paulirish/caltrainschedule.io/graphs/contributors). `#sosage`


### dev

To update caltrain GTFS data. (gtfs: [wiki](https://en.m.wikipedia.org/wiki/General_Transit_Feed_Specification), [class diagram](https://commons.wikimedia.org/wiki/File:GTFS_class_diagram.svg#mw-jump-to-license))
```sh
# download latest
rake download_data

# reset line endings..
dos2unix gtfs/*.txt

# then
rake prepare_data

# then update bombardiers manually from http://www.caltrain.com/Page4354.aspx
# see also http://www.caltrain.com/about/statsandreports/commutefleets.html


# manually squash data/*.js into bottom of index.html
```

#### Thanks

This is a fork of https://github.com/ranmocy/rCaltrain - he did fantastic work. Thank you.
