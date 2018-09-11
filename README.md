# Openoffice 3 headless daemon
Image running the OpenOffice 3 soffice daemon service

This image was created following the **General Container Image Guidelines** for Openshift. See the example here https://github.com/RHsyseng/container-rhel-examples/tree/master/starter-arbitrary-uid

## Build this image:

```
 docker build --pull -t rafaeltuelho/openoffice3-daemon --build-arg OO_VERSION=3.2.0 .
```

## Run the container

```
docker run -it -u 123456 --name=soffice rafaeltuelho/openoffice3-daemon -p 8100:8100
starting soffice daemon as user default [id uid=123456(default) gid=0(root) groups=0(root)]
```

When you run this image the container will start the Openoffice daemon in headless mode listening on TCP port `8100` by default. To change this port pass the env var `SOFFICE_DAEMON_PORT`

## Verify the daemon port is listening for connections

```
docker exec -it soffice test
```

## Add this container as sidecar for any app depends on Openoffice for any reason (eg. PDF generation).

 * import the image and create an Openshift `ImageStream`

```
oc import-image openoffice3-daemon --from=docker.io/rafaeltuelho/openoffice3-daemon --confirm --scheduled
```

 * edit your `DeploymentConfig` to include the `soffice` container inside your App **POD**

```yaml
...
    spec:
      containers:
        - image: >-
            docker.io/rafaeltuelho/openoffice3-daemon@sha256:<image tag sha256>
          imagePullPolicy: Always
          name: soffice
          ports:
            - containerPort: 8100
              protocol: TCP
...
  test: false
  triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
          - soffice
        from:
          kind: ImageStreamTag
          name: 'openoffice3-daemon:latest'
          namespace: demo-tomcat6
        lastTriggeredImage: >-
          docker.io/rafaeltuelho/openoffice3-daemon@sha256:<image tag sha256>
      type: ImageChange
...
```