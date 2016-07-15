.DEFAULT_GOAL := dist/dit4c-router-ngrok2.aci

CLIENT_INSTALLER_URL=https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
ACBUILD_VERSION=0.3.1
DOCKER2ACI_VERSION=0.12.0
ACBUILD=build/acbuild

dist/dit4c-router-ngrok2.aci: build/acbuild build/library-debian-8.aci build/ngrok | dist
	sudo rm -rf .acbuild
	sudo $(ACBUILD) --debug begin ./build/library-debian-8.aci
	sudo $(ACBUILD) copy build/ngrok /usr/bin/ngrok
	sudo $(ACBUILD) copy jwt /usr/bin/jwt
	sudo $(ACBUILD) environment add DIT4C_INSTANCE_PRIVATE_KEY ""
	sudo $(ACBUILD) environment add NGROK_REGION au
	sudo $(ACBUILD) environment add NGROK_BACKEND ""
	sudo $(ACBUILD) environment add JWT_KID ""
	sudo $(ACBUILD) environment add JWT_ISS ""
	sudo $(ACBUILD) copy build/ngrok /usr/bin/ngrok
	sudo $(ACBUILD) copy ngrok2.conf /etc/ngrok2.conf
	sudo $(ACBUILD) copy run.sh /opt/bin/run.sh
	sudo $(ACBUILD) copy listen_for_url.sh /opt/bin/listen_for_url.sh
	sudo $(ACBUILD) copy notify_portal.sh /opt/bin/notify_portal.sh
	sudo $(ACBUILD) run -- sh -c 'DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y curl && apt-get clean'
	sudo $(ACBUILD) set-name dit4c-router-ngrok2
	sudo $(ACBUILD) write --overwrite dist/dit4c-router-ngrok2.aci
	sudo $(ACBUILD) end

dist:
	mkdir -p dist

build:
	mkdir -p build

build/library-debian-8.aci: build/docker2aci
	cd build && ./docker2aci docker://debian:8

build/acbuild: | build
	curl -sL https://github.com/appc/acbuild/releases/download/v${ACBUILD_VERSION}/acbuild-v${ACBUILD_VERSION}.tar.gz | tar xv -C build
	mv build/acbuild-v${ACBUILD_VERSION}/acbuild build/acbuild
	rm -rf build/acbuild-v${ACBUILD_VERSION}

build/docker2aci: | build
	curl -sL https://github.com/appc/docker2aci/releases/download/v${DOCKER2ACI_VERSION}/docker2aci-v${DOCKER2ACI_VERSION}.tar.gz | tar xvz -C build
	mv build/docker2aci-v${DOCKER2ACI_VERSION}/docker2aci build/docker2aci
	rm -rf build/docker2aci-v${DOCKER2ACI_VERSION}

build/ngrok: | build
	curl -sL https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip > build/ngrok.zip
	unzip -d build build/ngrok.zip
	rm build/ngrok.zip

clean:
	-rm -rf build .acbuild dist