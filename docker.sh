#!/bin/bash

echo -n "Do you want to build an image for the app in this directory? (y/n): "
read ans
if [ "$ans" == "y" ]; then
	echo -n "Please provide a name for the image: "
	read name
	echo -n "Please provide a tag for the image: "
	read tag
	if [[ -z "${name}" || -z "${tag}" ]]; then
		echo "ERROR: name and tag are required and cannot be empty"
		echo "Image creation aborted"
		exit 1
	else 
	docker build -t ${name}:${tag} . > /dev/null 2>&1
	echo "The docker image with name ${name} and tag ${tag} has been built."
	echo
	fi
fi




echo -n "Do you want to run the image? (y/n): "
read ans
if [ "$ans" == "y" ]; then
	echo -n "Do you want to add add MEMORY and/or CPU limit for the image? (y/n): "
	read subans
	if [ "$subans" == "y" ]; then
		echo "The MEMORY format is [number][unit], e.g. [1g] for 1GB, [2m] for 2MB, etc."
		echo "The MEMORY limit is infinte if not specified."
		echo -n "Enter the MEMORY limit: "
		read mem
		echo "The CPU limit depends on how much available CPU you have on your machine."
		echo "Please read the documentation for more information."
		echo "The CPU limit is %100 if not specified."
		echo "Enter the CPU limit in cores: "
		read cpu
		if [[ -z "${mem}" && ! -z "${cpu}" ]]; then
			echo "MEMORY limit is not specified and default value will be used."
			echo "Running image with ${cpu} CPU limit ..."
			docker run -d --cpus="${cpu}" ${name}:${tag} > /dev/null 2>&1
		elif [[ ! -z "${cpu}" && -z "${mem}" ]]; then
			echo "CPU limit is not specified and default value will be used."
			echo "Running image with ${mem} MEMORY limit ..."
			docker run -d --memory="${mem}" ${name}:${tag} > /dev/null 2>&1
		elif [[ -z "${mem}" && -z "${cpu}" ]]; then
			echo "MEMORY and CPU limit are not specified and default value will be used."
			echo "Running image without MEMORY and CPU limit..."
			docker run -d ${name}:${tag}
		else
			docker run -d --memory="${mem}" --cpus="${cpu}" ${name}:${tag} > /dev/null 2>&1
		fi
		if [ $? == *"invalid" ]; then
			echo "The image has been runned successfully."
		else
			echo "ERROR: The image has not been runned due to invalid format of CPU or MEMORY limit."
			echo "Image run aborted"
			exit 1
		fi
	fi
fi



echo "Do you want to push the image? (y/n)"
read ans
if [ "$ans" == "y" ]; then
	echo "With this script you can put your image either on Docker Hub or GitLab."
	echo "If you want to use Docker Hub, enter 1. If you want to use GitLab, enter 2."
	read ans
	if [ "$ans" == "1" ]; then
		echo -n "Please give your Docker Hub username: "
		read username
		echo -n "Please give your Docker Hub password: "
		read -s password
		docker login -u="${username}" -p="${password}"
		docker image tag ${name}:${tag} ${username}/${name}:${tag}
		docker image push ${username}/${name}:${tag}
		#docker push app
	elif [ "$ans" == "2" ]; then
		echo -n "Please give your GitLab username: "
		read username
		echo -n "Please give your GitLab password: "
		read -s password
		echo -n "Please give your GitLab project name: "
		read project
		docker login -u="${username}" -p="${password}" registry.gitlab.com
		docker image tag ${name}:${tag} registry.gitlab.com/${project}/${name}:${tag}
		docker image push registry.gitlab.com/${project}/${name}:${tag}
	else
		echo "Invalid input."
	fi
	
fi

echo "Do you need a database? (y/n)"
read ans
if [ "$ans" == "y" ]; then
	echo "With this script we only provide mysql and mongo."
	echo "If you want to use mysql, enter 1. If you want to use mongo, enter 2."
	read subans
	if [ "$subans" == "1" ]; then
		echo "mysql worked."
	elif [ "$subans" == "2" ]; then
		echo "mongo worked."
	else
		echo "Invalid input."
	fi
fi
