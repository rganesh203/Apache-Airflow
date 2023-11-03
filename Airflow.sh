# IDE 
	pycharm, VS code, sublime text, vim GNU Emacs, Spyder, atom, jupyter, eclipse, notepad++, intellije.
	
# visual studio code scope
	c#, visual basic, java-script, R, XML, Python, CSS, GO, PERL.
	1. ctrl+ zoom
	2. settings---->font size 25, autosave(afterdelay)
	3. settings---->file icon theme--->material icon theme--->install--->click material icon theme
	4. Extensions: python, python preview, aerpl, .run, 

# Throughout the course, you will learn:
# Airflow Introduction
	What is Airflow?
		starts in airbnd 2014
		manage comples workflows
		top-level apache project 2019 workflow management paltform 
		written in Python
#Run Airflow in Python Env
	craete visual studio: python >3.6
	pwd
	python --version
	python3 -m venv py_env
	source py_env/bin/activate
	pip install apache-airflow==2.0.1
	pip install 'apache-airflow==2.6.1' \
	--constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.6.1/constraints-3.7.txt"
	#an error
	xcode-select
	export airflow_home=.
	#database
	airflow db init
	airflow webserver -p 8080
	#open with browser
	airflow users create --help

#Run Airflow in Docker
	#create new folder
	#https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html
	#https://docs.docker.com/engine/install/
	#https://docs.docker.com/desktop/install/windows-install/
	#https://docs.docker.com/desktop/install/linux-install/
	pwd
	docker --version
	docker-compose --version
	curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.6.1/docker-compose.yaml'
	mkdir -p ./dags ./logs ./plugins ./config
	echo -e "AIRFLOW_UID=$(id -u)" > .env
	docker compose up airflow-init
	docker compose up -d
	docker ps
	0.0.0.0
#Airflow Basics and Core Concepts workflow?

	DAG:  it is sequence of task, in airflow, workflow as DAG, namely directed acyclic graph. 
	Task: it is unit of work within a DAG, 
	Operator: is the goal of the task is to achieve specific thing, the method it uses is called operator.
				bashoperator, oythonoperator, customized operator
	Execution Date: is the logical date and time which dag runand its task instances are running for.
	Task Instance: is a run of task at a specific point of time. 
	Dag Run: is an instantiation of a dag, containing task instances taht run for specific Execution_time.

#Airflow Task Lifecycle
	there are i 11 different kinds of stages . in the airflor UI(graph and tree views)
		no_status
		scheduled
		queued
		running
		success
		upstream_failed
		up_for reschedule
		skipped
		up_for_retry
		failed
		shutdown
	task starts with no_status scheduler created empty task instance
		no_status----->scheduler
							scheduled---->executer---->queued--->worker---->running(success, ((failed, shutdown)up for retry))
							removed
							upstream failed
							skipped
#Airflow Basic Architecture
	Airflow provides operators for many common tasks, including:

	BashOperator - executes a bash command

	PythonOperator - calls an arbitrary Python function

	EmailOperator - sends an email

	SimpleHttpOperator - sends an HTTP request

	MySqlOperator, SqliteOperator, PostgresOperator, MsSqlOperator, OracleOperator, JdbcOperator, etc. - executes a SQL command

	Sensor - an Operator that waits (polls) for a certain time, file, database row, S3 key, etc…

	In addition to these basic building blocks, there are many more specific operators: 
	DockerOperator, HiveOperator, S3FileTransformOperator, PrestoToMySqlTransfer, SlackAPIOperator… you get the idea!

	Operators are only loaded by Airflow if they are assigned to a DAG.
#Airflow DAG with Bash Operator
	from airflow import DAG
	from datetime import datetime, timedelta 
	from airflow.operators.bash import BashOperator
	
	default_args ={
			'owner': 'coder2j',
			'retries':5,
			'retry_delay': timedelta(minutes=2)
	}
	with DAG(dag_id='our_first_dag_v4', 
			default_args=default_args,
			description='this is our first dag that we write',
			start_date=datetime(2021, 7, 29, 2),
			schedule_interval='@daily'
	) as dag:
		task1=BashOperator(
            task_id='first_task',
            bash_command='echo "HELLO!"'
		)
		task2=BashOperator(
        task_id='second_task',
        bash_command="echo hey, I am task2 and will be running after task1"
		)
		task3=BashOperator(
        task_id='third_task',
        bash_command="echo hey, I am task2 and will be running after task1"
		)
		#task dependency method 1
		#task1.set_downstream(task2)
		#task1.set_downstream(task3)
		
		#task dependency method 2
		task1 >> task2
		task1 >> task3
		
		#task dependency method 3
		task1 >> [task2,task3]	
	
#Airflow DAG with Python Operator
		docker ps
		docker-compose up -d
		#create .py file
		from airflow import DAG
		from datetime import datetime, timedelta 
		from airflow.operators.bash import BashOperator
		
		def greet(name,age):
			print(f"HELLO world! my name is {name},"
			f"and I am {age} years ols")
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=5)
		}
		with DAG(dag_id='our_dag_with_python_operator_01', 
				default_args=default_args,
				description='this is our first dag that we write',
				start_date=datetime(2021, 10, 6),
				schedule_interval='@daily'
		) as dag:
			task1=PythonOperator(
				task_id='greet',
				python_callable=greet,
				op_kwargs={'name': 'ganesh','age':36}
			)
			task1 
			
#Data Sharing via Airflow XComs
		from airflow import DAG
		from datetime import datetime, timedelta 
		from airflow.operators.bash import BashOperator
		
		def greet(age,ti):
		first_namename=ti.xcom_pull(task_ids='get_name', key='first_name')
		first_namename=ti.xcom_pull(task_ids='get_name', key='last_name')
		
			print(f"HELLO world! my name is {firts_name}{last_name}"
			f"and I am {age} years ols")
		
		def get_name(ti):
			ti.xcom_push(key='first_name', value='jerry')
			ti.xcompush(key='last_name', value='Fridam')
		
		def get_name(ti):
			ti.xcom_push(key='age')
		
		
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=5)
		}
		with DAG(dag_id='our_dag_with_python_operator_v05', 
				default_args=default_args,
				description='this is our first dag that we write',
				start_date=datetime(2021, 10, 6),
				schedule_interval='@daily'
		) as dag:
			task1=PythonOperator(
				task_id='greet',
				python_callable=greet,
				op_kwargs={'name': 'ganesh'}
			)
			task1 
			
			task2=PythonOperator(
				task_id='get_name',
				python_callable=get_name
			)
			task2=PythonOperator(
				task_id='get_age',
				python_callable=get_age
			)
						
			task2>>task1
			[task3,task2]>>task1
#Airflow Task Flow API
		#create .py file
		from airflow import DAG
		from datetime import datetime, timedelta 
		from airflow.decrators.bash import task, dag
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=5)
		}
		@dag(dag_id='our_dag_with_python_operator_v05', 
				default_args=default_args,
				description='this is our first dag that we write',
				start_date=datetime(2021, 10, 6),
				schedule_interval='@daily')
		def hello_world_etl():
			
			@task(multiple_output=True)
			def get_name():
				return {'first_name':"jerry", 'last_name': 'jathin'}
				
			
			@task()
			def get_age():
				return 19
				
			@task()
			def greet (name, age):
				print(f"hello world! my name is {name} and iam {age} years old")
			name_dict = get_name()
			age = get_age()
			greet(first_name=name_dict['first_name'],last_name=name_dict['last_name'], age=age)
		
		greet_dag =hello_world_etl()		
		
#Airflow Catch-Up and Backfill
		# new file
		from airflow import DAG
		from datetime import datetime, timedelta 
		from airflow.operators.bash import BashOperator
		
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=2)
		}
		with DAG(dag_id='dag_with_catchup_backfill_v02', 
				default_args=default_args,
				start_date=datetime(2021, 11, 1),
				schedule_interval='@daily'
				#capture=True
				capture=True
				
		) as dag:
			task1=BashOperator(
				task_id='task1',
				bash_command='echo this is a simple bash command'
			)
		
		docker exec -it c4bc255242a1 bash
		airflow dags backfill -s 2021-11-01 -e 20121-11-08
		dag_with_catchup_backfill_v02
		exit
		
#Airflow Scheduler with Cron Expression
		schedule interval ---->(datetime.timedelta, Cron Expression)
		cron Expression: is a string comprising five field seperated by white space that represents a set of times, normally as aschedule to execute some routine.
		#new file
		
		from airflow import DAG
		from datetime import datetime, timedelta 
		from airflow.operators.bash import BashOperator
		
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=2)
		}
		with DAG(dag_id='dag_with_cron_expression_v01', 
				default_args=default_args,
				start_date=datetime(2021, 11, 1),
				schedule_interval='0 3 * * Tue' #'0 3 * * Tue, Wed, Thu, Fri'
				
				
		) as dag:
			task1=BashOperator(
				task_id='task1',
				bash_command='echo dag with cron expression'
			)
		#crontab.guru website
		#Airflow Connection
		
		DAG:	Credentials(host,user, pass,___)---> Database Servers 
												---> Cloud Servers
												---> Others
		Admin-----> connections----->+---> conn type
# Airflow Connection to Postgres
		#1.
		version: '3.8'
		services:
		  db:
			image: postgres:14.1-alpine
			restart: always
			environment:
			  - POSTGRES_USER=postgres
			  - POSTGRES_PASSWORD=postgres
			ports:
			  - '5432:5432'
			volumes: 
			  - db:/var/lib/postgresql/data
		volumes:
		  db:
			driver: local
		#2.
		version: '3.8'
		services:
		  db:
			image: postgres:14.1-alpine
			restart: always
			environment:
			  - POSTGRES_USER=postgres
			  - POSTGRES_PASSWORD=postgres
			ports:
			  - '5432:5432'
			volumes: 
			  - db:/var/lib/postgresql/data
			  - ./db/init.sql:/docker-entrypoint-initdb.d/create_tables.sql
		  api:
			container_name: quotes-api
			build:
			  context: ./
			  target: production
			image: quotes-api
			depends_on:
			  - db
			ports:
			  - 3000:3000
			environment:
			  NODE_ENV: production
			  DB_HOST: db
			  DB_PORT: 5432
			  DB_USER: postgres
			  DB_PASSWORD: postgres
			  DB_NAME: postgres
			links:
			  - db
			volumes:
			  - './:/src'
		volumes:
		  db:
			driver: local
		
		#3.
		version: '3.5'
		services:
		  postgres:
			container_name: postgres_container
			image: postgres
			environment:
			  POSTGRES_USER: ${POSTGRES_USER:-postgres}
			  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-changeme}
			  PGDATA: /data/postgres
			volumes:
			   - postgres:/data/postgres
			ports:
			  - "5432:5432"
			networks:
			  - postgres
			restart: unless-stopped
		  
		  pgadmin:
			container_name: pgadmin_container
			image: dpage/pgadmin4
			environment:
			  PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL:-pgadmin4@pgadmin.org}
			  PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD:-admin}
			  PGADMIN_CONFIG_SERVER_MODE: 'False'
			volumes:
			   - pgadmin:/var/lib/pgadmin

			ports:
			  - "${PGADMIN_PORT:-5050}:80"
			networks:
			  - postgres
			restart: unless-stopped

		networks:
		  postgres:
			driver: bridge

		volumes:
			postgres:
			pgadmin:
#Airflow Postgres Operator
		dbeaver 
		install jdbc postgre 
		#create a .py
		from airflow import DAG
		from datetime import datetime, timedelta 
		from airflow.providers.postgres.operators.postgres import postgresOperator
		
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=5)
		}
		with DAG(dag_id='dag_with_cron_expression_v01', 
				default_args=default_args,
				start_date=datetime(2021, 11, 1),
				schedule_interval='0 0 * * *' 
		) as dag:
		task1_id=PostgresOperator('create_postgres_table'
		postgres_com_id='postgre_localhost',
		sql="""create table if not exists dag_runs 
			(dt date,
			dag_id character varying,
			primary key (dt, dag_id)
			)
			"""
		)
		
		task2=PostgresOperator(
		task_id='postgre_localhost',
		postgres_conn_id='postgre_localhost',
		sql="""insert into dag_runs (ds, dag_id) values('{{dt}}', '{{dag.dag_id}})
		
			"""
		)
		task3=PostgresOperator(
		task_id='delete_data_from_table',
		postgres_conn_id='postgre_localhost',
		sql="""
			delete from dag_runs where dt= '{{ds}}' and dag_id= '{{dag.dag_id}})
		
			"""
		)
		task1>>task3>>task2
		#goto connection 
		add postgre
		host---->local
#Airflow Docker Install Python Package 2 ways
		#image extending 
		#open folder
		#create requirement.txt file
		scikit-learn==0.24.2
		matplotlib==3.3.3
		#create Dockerfile
		from apache/airflow:2.0.1
		COPY requirement.txt/requirement.txt
		RUN pip install --user --upgrade pip
		Run pip install --no-cache-dir --user -r /requirement.txt
		#goto terminal 
		docker build . --tag extending_airflow:latest
		# open compose yaml file change image -extending_airflow:latest
		# create dag_with_python_dependencies.py 
		from airflow import DAG
		from datetime import datetime, timedelta 
		from airflow.providers.postgres.operators.postgres import postgresOperator
		
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=5)
		}
		
		def get_sklearn():
			import sklearn
			print(f"scikit-learn with version: {sklearn.__verion}")
		
		def get_matplotlib():
			import matplotlib
			print(f"matplotlib-learn with version: {matplotlib.__verion}")
		with DAG(dag_id='dag_with_python_dependencies_v02', 
				default_args=default_args,
				start_date=datetime(2021, 11, 1),
				schedule_interval='@daily' 
		) as dag:
			get_sklearn=PythonOperator(
			task_id='get_sklearn'
			python_callable=get_sklearn
		)
		get_sklearn
		
		get_sklearn=PythonOperator(
			task_id='get_matplotlib'
			python_callable=get_matplotlib
		)
		get_sklearn
		docker-compose up -d --no-deps --build airflow-weserver airflow-scheduler
	
	#2. vs image customising
	#goto Dockerfile
		#terminal 
			cd
			pwd
			git clone https://github.com/apache/airflow.git
		open new vs code file
		create requirement.txt
		scikit-learn==0.24.2
		matplotlib==3.3.3
		Docker build . --build-arg AIRFLOW_Version='2.0.1'--tag customising_airflow:latest
		pwd
		docker-compose up -d --no-deps --build airflow-weserver airflow-scheduler
		
#Airflow AWS S3 Sensor Operator
		# it is a special type of Operator which waits for something to occur
			use case: -donnot know exact time when the file exixts
			amazon s3----->MINIO
			docker run \
		  -p 9000:9000 \
		  -p 9001:9001 \
		  -e "MINIO_ROOT_USER=AKIAIOSFODNN7EXAMPLE" \
		  -e "MINIO_ROOT_PASSWORD=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
		  quay.io/minio/minio server /data --console-address ":9001"
			#copy url and paste it in browser
			enter
			user and password
			create bucket
			VS code create folder data
			and create file name data.csv
			drag and drop into bucket
			# create dag_with_minio_s3.py file
		from airflow import DAG
		from datetime import datetime, timedelta 
		
		
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=5)
		}
		with DAG(dag_id='dag_with_minio_s3_v01', 
			start_date=datetime(2022, 2, 12),
			schedule_interval='@daily' 
			default_args=default_args
		) as dag:
			pass
		#goto yaml file:
		image: ${AIRFLOW_IMAGE_NAME: -extending_airflow:latest}
		#open terminal 
		docker-compose up -d --no-deps --build airflow-weserver airflow-scheduler
		docker exec -it f9f5bddf01f5 bash 
		pip list | grep amazon
		apache airflow documentation
		amazon 1.1.0
		python API
		#https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/_api/airflow/providers/amazon/aws/sensors/s3/index.html
		#open dag_with_minio_s3.py file
		from airflow.provider.amazon.aws.sensors.s3_key import S3KeySensor
		task_id = S3KeySensor(
		task_id='sensor_minio_s3',
		bucket_name ='airflow',
		bucket_key='data.csv',
		#open new Connection
		aws_conn_id='minio_conn'
		mode='poke',
		poke_interval=5
		timeout=30
		)	
		
#Airflow Hooks S3 PostgreSQL
		#create orders.csv
		#import file into PostgreSQL
		#create dag_with_Postgre_hooks.py
		import csv
		import logging
		from airflow import DAG
		from datetime import datetime, timedelta 
		from airflow.operators.python import PythonOperator
		from airflow.providers.postgres.hooks.postgres import PostgresHook
		
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=10)
		}
		def postgre_to_s3():
			
			#step 1: query from PostgreSQL db and save into text file
			hook= PostgresHook(postgres_conn_id='postgre_localhost')
			conn =hook.get_conn()
			cursor=conn.cursor()
			cursor.execute("select * from order where date <=20220201")
			with open ("dags/get orders.txt","w") as f:
				csv_writer=csv.writer(f)
				csv_writer.writerow([i[0] fo i in cursor.description])
				csv_writer.writerows(cursor)
			cursor.close()
			conn.close()
			logging.info("saved orders data in text file get_orders.txt")
			
			#step 2: upload text file into S3
			
		
		with DAG(dag_id='dag_with_postgres_hooks_v01', 
			start_date=datetime(2022, 2, 12),
			schedule_interval='@daily' 
			default_args=default_args
		) as dag:
			task1 = PythonOperator
			(task_id="postgres_to_s3",
			python_callable=postgres_to_s3
			)
			task1
			
		#open terminal
		docker ps
		docker exec -it 258e6f9c30e4 bash
		pip list |grep Postgres
		
		import csv
		import logging
		from airflow import DAG
		from datetime import datetime, timedelta 
		from airflow.operators.python import PythonOperator
		from airflow.providers.postgres.hooks.postgres import PostgresHook
		from airflow.providers.amazon.aws.hooks.s3 import s3Hook		
		from tempfile import NamedTemporaryFile
		default_args ={
				'owner': 'coder2j',
				'retries':5,
				'retry_delay': timedelta(minutes=10)
		}
		def postgre_to_s3():
			
			#step 1: query from PostgreSQL db and save into text file
			hook= PostgresHook(postgres_conn_id='postgre_localhost')
			conn =hook.get_conn()
			cursor=conn.cursor()
			cursor.execute("select * from order where date <=20220201")
			with NamedTemporaryFile(mode='w', suffix=f"{ds_nodash}" as f:
			#with open ("dags/get orders_{ds_nodash}.txt","w") as f:
				csv_writer=csv.writer(f)
				csv_writer.writerow([i[0] fo i in cursor.description])
				csv_writer.writerows(cursor)
				f.flush()
				cursor.close()
				conn.close()
				logging.info("saved orders data in text file: %s", f"dag/get_orders get_orders.txt")
			#step 2: upload text file into S3
				s3_hook = S3Hook(aws_conn_id="mino_conn")
				s3_hook.load_file(
					filename=f"dags/get_orders_{ds_nodash}.txt",
					key=f"orders/{ds_nodash}.txt",
					bucket_name="airflow"
					replace =True
				)	
				logging.info("orders file %s has been pushed to S3")
			
		with DAG(dag_id='dag_with_postgres_hooks_v03', 
			start_date=datetime(2022, 2, 12),
			schedule_interval='@daily' 
			default_args=default_args
		) as dag:
			task1 = PythonOperator
			(task_id="postgres_to_s3",
			python_callable=postgres_to_s3
			)
			task1
			
		#login to 
# Course Bonus

	'XComs (short for “cross-communications”) 
	are a mechanism that let Tasks talk to each 
	other, as by default Tasks are entirely 
	isolated and may be running on entirely 
	different machines. An XCom is identified 
	by a key (essentially its name), as well 
	as the task_id and dag_id it came from.'
#  5 MUST KNOW Airflow debug tips and tricks | Airflow Tutorial Tips 1
	#1. DAG type error
		1. python extention
		2. Execute DAG python file
		3. Airflow DAG error
	#2. DAG Takes long time to show up
	#3. DAG/TASK not Running
	#4. DAG/task Runs failed
	#5. scheduler is not running
	
# Remove airflow example dags