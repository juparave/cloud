original: https://github.com/juparave/turbogears/blob/master/libcloud.md

# libcloud for Rackspace Cloudfiles

[Apache Libcloud](http://libcloud.apache.org/)

Install

    $ pip install apache-libcloud

```python
import libcloud
from libcloud.compute.types import Provider
from libcloud.compute.providers import get_driver

api_key = "xxxx2f5658bc65df8cb3a39f09a7bfe7"
username = "username"

# cloudfiles is the driver for RackSpace
cls = libcloud.get_driver(libcloud.DriverType.STORAGE, libcloud.DriverType.STORAGE.CLOUDFILES)
# all files are stored in the nearest location Dallas Forth Worth
driver = cls(username, api_key, region='dfw')
# create container
container = driver.create_container("test")
# if container already created, get the container
container = driver.get_container("test")
```

## Upload Object

[Examples](https://libcloud.readthedocs.io/en/stable/storage/examples.html)

```python
file_path = '/Users/pablito/Downloads/119136872_4470785782964095_7197786911271636876_n.jpg'
file_name = '/photos/119136872_4470785782964095_7197786911271636876_n.jpg'

# upload_object(file_path, container, object_name, extra=None, verify_hash=True, headers=None)
obj = driver.upload_object(file_path, container, file_name)
```

`file_name` notice path of the file to be stored.  That's to store the image file inside `photos` 

Get object's url

    $ obj.get_cdn_url()
    'http://04cf17f8f3374aa334ea-592b1ac9322c9b1b97aa36f03ced8aa2.r82.cf1.rackcdn.com/photos/119136872_4470785782964095_7197786911271636876_n.jpg'

We will replace `http` with `https` to avoid security errors on browser

    $ obj.get_cdn_url().replace('http', 'https')
    'https://04cf17f8f3374aa334ea-592b1ac9322c9b1b97aa36f03ced8aa2.r82.cf1.rackcdn.com/photos/119136872_4470785782964095_7197786911271636876_n.jpg'
    

Adding optional extra values

```python
extra = {'meta_data': {'owner': 'myuser', 'created': '2020-09-15'}}
obj = driver.upload_object(file_path, container, file_name)
```

Uploading using streams

```python
with open(file_path, 'rb') as iterator:
    obj = driver.upload_object_via_stream(iterator=iterator,
                                          container=container,
                                          object_name='file_name',
                                          extra=extra)
```

