# [caltrainschedule.io](https://caltrainschedule.io/)

Service worker enabled for offline and add to homescreen excellence.

![image](https://cloud.githubusercontent.com/assets/39191/15494867/a3f2a7c2-2141-11e6-9793-9b38e03aa6cf.png)

This is a @samccone & @paulirish collab. Also probably [other awesome people](https://github.com/paulirish/caltrainschedule.io/graphs/contributors). `#sosage`


### dev

To update caltrain GTFS data. (gtfs: [wiki](https://en.m.wikipedia.org/wiki/General_Transit_Feed_Specification), [class diagram](https://commons.wikimedia.org/wiki/File:GTFS_class_diagram.svg#mw-jump-to-license))
```sh
# probably want to use rvm because ruby bundles and version compat is hard
rvm

# download latest, reset line endings, prepare data
rake download_data && dos2unix gtfs/*.txt && rake prepare_data

# inline data into the index.html, refresh the timestamp, bump the sw
yarn build
```

### test

```sh
yarn test # does both of the below, in order


yarn unit:dl # download the latest times from the online schedule. Adjust the results and save to JSON.
yarn unit # open the app, fetch the JSON files, then assert the schedules are equal clientside.
          # Puppeteer will report if the page says there are failures or not.
```

#### Thanks

This is a fork of https://github.com/ranmocy/rCaltrain - he did fantastic work. Thank you.
