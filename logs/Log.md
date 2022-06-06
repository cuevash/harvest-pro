# LOG

## 2022/02/25

* Create a PowerBI project. It is already created and is called Harvest.

* Following the best practices, we create a dataset where the ETL of data is done, as well as the modelization of the BI model.
  
* So, the initial dataset "Harvest Pro Dataset v1.0.0" is created with PowerBI Desktop.

## 2022/03/15

* The first phase is to extract the data from Harvest using its API. To do that the tool <https://airbyte.com/>
will be used. It has several connectors to extract and move data from several sources and targets.
On this case airbyte will be used to extract from harvest to a <https://www.cockroachlabs.com/> DB tool.
The cockroachlabs DB is a postgress compatible DB that is hugely scalable and distributed. The advantage for this case scenario is that it is free until certain size and usage and that is compatible with postgresSQL.

Once that the data is in cockroachlabs it will be loaded to PowerBI. And then the cleaning, transformation and creation of the semantic model will be carried out.

* As the airbytes's connector for harvest gives and error when using it out of the box, it is needed to extend given connector and fixed the issue causing the error. And that is the task for today.

## 2022/03/16

* Learning the cockroachlabs DB

## 2022/03/28

* After examining all the possible options, the conclusion is that: the best option would be to install it in Kubernetes cluster. In order to do that there are some pretty cool new tools that manage the deployment and lifecycle of OSS software into Kubernetes.
For instace have a look to:
* <https://www.restack.io/> (in invite mode only yet)
* <https://www.plural.sh/>

They look awesome! But.. The problem is not in the tools, it is in the rather pricey cost of the Kubernetes offering from big cloud providers. I found a fantastic cloud provider that looks a bit like a mini GCP and at a fraction of the cost. Especially for the cost of a Kubernetes cluster.
Unfortunately the plural.sh tool (the only one opened to the public so far) does not support this cloud provider.
There may be a way to customize the tool to support it, and it should be something to consider in the future. But, not right now.
So, if we are not willing to use the Kubernetes cluster because it is so expensive, then what options we have we left?.

* Deploy the Kubernetes repo option into a cheaper Kubernetes cluster, like the one in scaleway.
This is an interesting option because of its reduction in price.. But needs to be studied a bit deeper to analyze the cost in time to manage it because it is somehow a more manual way to handle a
Kubernetes cluster.
* Using a GCP optimized for docker VM. And use the docker composer image to deploy it. On top of that create a Google cloud SQL Postgres database for the Airbyte to use.
Also, we may need to set up the output of the logging system.

* Resolution:
After analyzing both solutions we will go initially for the GCP optimized VM based upon the instructions on <https://docs.airbyte.com/deploying-airbyte/on-gcp-compute-engine>

But we will combine those instructions with the use of cloud_init (<https://cloud-init.io/>). The cloud_init code will be based on these instructions: <https://medium.com/@sachin.d.shinde/docker-compose-in-container-optimized-os-159b12e3d117>

* When doing an ssh to the instance a 'hector' user is created. If we do an ssh from the browser a 'cuevas_sp' use is created. This is because the ssh command uses the user from the user active.
In order to simplify this and always use the same user irrespective of where we do an ssh see
 👍<https://cloud.google.com/compute/docs/oslogin/>

* after creating an optimized VM for containers.

* Defining the startup script
      *First we create the metadata value user:cuevash_sp_gmail_com (name created by using authorization by iam)
      * Using that value the startup script will be:

````shell
#! /bin/bash
# In your ssh session on the instance terminal
LOGIN_USER=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/user -H "Metadata-Flavor: Google")
echo $LOGIN_USER | cat > /etc/startup-user.txt

export DIR="/home/${LOGIN_USER}"
if [ -d "${DIR}" ]; then
  ### If DIR exists it means that is not the first time and so that the $LOGIN_USER has been added already
  ### adding $LOGIN_USER to docker group
  echo "Installing config files in ${DIR}..."
  echo "Installing config files in ${DIR}..." | cat > /etc/startup-user_dir.txt
  sudo usermod -aG docker $LOGIN_USER
  cd ${DIR} 
sudo -u cuevash_sp_gmail_com bash -c 'echo "Installing config files in ${DIR} \${PWD}:\${PWD}..." | cat > /tmp/pwds.txt; \
    docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD:$PWD" \
    -w="$PWD" \
    docker/compose up'
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Error: ${DIR} not found. Can not continue."
  echo "Error: ${DIR} not found. Can not continue." | cat > /etc/startup-user_dir.txt
  exit 1
fi
````

In the end we will use cloud_init to make these startup initializations. Cloud_init is more standard. The instructions above are left as helpful example of how to use startup script.

## 2022/03/30

* Based on the initial tests of creating VMs yesterday we will:
  * Create VM with optimized os for containers.
    *
  * Add cloud_init instructions to setup docker_compose
  * Add the rest of instructions in cloud_init to run airbyte based on <https://docs.airbyte.com/deploying-airbyte/on-gcp-compute-engine> and <https://medium.com/@sachin.d.shinde/docker-compose-in-container-optimized-os-159b12e3d117>

    * Add cos-cloudinit.sh file to storage
    * Run the shell command to create the VM with the given cos-cloudinit.sh file as startup instructions

````shell
gcloud compute instances create airbyte-cluster-2 \
--project=harvest-pro-342720 \
--zone=europe-west1-b \
--machine-type=e2-medium \
--network-interface=network-tier=PREMIUM,subnet=default \
--metadata=user=cuevash_sp_gmail_com,enable-oslogin=true \
--metadata-from-file user-data=cos-cloudinit.sh \
--maintenance-policy=MIGRATE \
--service-account=1019074943065-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--tags=http-server,https-server \
--create-disk=auto-delete=yes,boot=yes,device-name=airbyte-cluster-2,image=projects/cos-cloud/global/images/cos-stable-93-16623-102-34,mode=rw,size=30,type=projects/harvest-pro-342720/zones/europe-west1-b/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--reservation-affinity=any
````

    * Can connect to port http:8000 in the machine, trying the tunnel on the instructions
      * gcloud --project=harvest-pro-342720 beta compute ssh airbyte-cluster -- -L 8000:localhost:8000 -N -f
      * It seems that can connect directly.. I dont know why?.. but the tunnel seems to make the trick!! 
      Yahooo!!

* Modify deployment to access an external database
* Modify deployment to log into an external and permanent disk of GCP storage or similar

## 2022/05/04

* Learning terraform to automatize the deployment of airbyte.
* Need to lean IAM from GCP to find out what's the best and most secured way to invoke API services on GCP.


## 2022/06/05

* Setting up a "Modern Data Stack" : https://towardsdatascience.com/bootstrap-a-modern-data-stack-in-5-minutes-with-terraform-32342ee10e79

* Installing tfenv -> version swapper for terraform, when you need to work with multiple versions.

* Creating a git standalone project harvest-pro in and removing it from bilayer.