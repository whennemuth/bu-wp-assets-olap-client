# Client for S3 assets

Run an apache server in a docker container that retrieves objects in an S3 bucket through object lambda access points.
[MORE DOCUMENTATION PENDING]

- **[Basic](./baseline/README.md)**
  The object lambda functionality retrieves content from s3 without checking any identifying information of the incoming request.
- **[Shibboleth](./shibboleth/README.md)**
  Builds on basic but adds to apache mod_shib service provider capability that sends requests to an IDP for login.
  Correspondingly, the object lambda code is extended to check for header/token information of a logged in user.