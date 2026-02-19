# Deploy!

Time to deploy your application. 

**Type**: Group work

---

## Assingment

You must deploy your application to a Azure Virtual Machine.    
You should create the WM, and it should run until after next teachings (tuesday).    
For now (in this exercise) you should deploy manually, meaning **not** through GitHub and GitHub actions, but from you commandline using `ssh` and `scp`.     

The result should look similar to this:

Backend : [http://51.120.70.34/api](http://51.120.70.34/api) 
Frontend : [http://51.120.70.34/](http://51.120.70.34/)
Documentation : [http://51.120.70.34/api](http://51.120.70.34/apidocs/) - not working for me, but it should for you! 

---

## PR to `groups.py`

Once you have deployed, create a PR to [groups.py](../../groups.py). The relevant part to replace is:

```python
            "backend": "http(s)://<IP_DOMAIN>/<APIURL>",
            "frontend": "http(s)://<IP_DOMAIN>/<FrontEndURL>",
            "stack": ["Flask", "Svelte", "CouchDB", "Redis"],
            "documentation": ["http(s)://<IP_DOMAIN>/<DocumentationURL>"],
```

Backend and frontend could be the same IP address. 

The `<APIURL>` and `<FrontEndURL>` parts are optional. For instance, if you prepend all your API with `v1`. The endpoints should be accessible given the values + the endpoints as defined in the OpenAPI specification.

Updating the stack is a great idea, since it allows you to connect with other groups using the same technology if you are stuck. You are encouraged to do so. 

Remember to make sure that your forked repository's state is up to date with the original repository before making your pull request.

On tuesday we will do a trial run on all you applications.
