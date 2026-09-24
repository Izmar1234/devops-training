### IAM Security tools 
## IAM Credentials Report (account-level)
    - a report that list all your account's users and the status of their various credentials. 
## IAM Access Advisor (user-level)
    - access advisor shows the service permissions ranted to a user and when those services were last accessed. 
    - you can use this information to revise your  policies.
### Types instances EC2 : 
| Instance Type | Common Families | Use Cases |
|---|---|---|
| General Purpose | `T`, `M` | Web servers, small databases, and development environments |
| Compute Optimized | `C` | Compute-intensive workloads, batch processing, video encoding, and game servers |
| Memory Optimized | `R`, `X`, `U`, `Z` | In-memory databases, SAP HANA, and large caches |
| Accelerated Computing | `P`, `G`, `F`, `Inf`, `Trn`, `DL` | AI/ML, GPUs, graphics rendering, FPGA, inference, and training |
| Storage Optimized | `I`, `D`, `H` | NoSQL databases, data warehouses, and high I/O workloads |
| High-Performance Computing | `Hpc` | Scientific simulations, weather forecasting, engineering, and HPC workloads |

### Common Ports to Remember  
21 :  FTP  
22 : SSH and SFTP  
3389 : RDP 

### EC2 Instance Purchasing Options  

| Purchasing Option | Commitment | Best For / Characteristics |
|---|---|---|
| On-Demand Instances | None | Short workloads, predictable pricing, billed per second |
| Reserved Instances | 1 or 3 years | Long-running workloads |
| Convertible Reserved Instances | 1 or 3 years | Long-running workloads requiring instance flexibility |
| Savings Plans | 1 or 3 years | Commitment to a certain amount of usage; suitable for long workloads |
| Spot Instances | None | Short, inexpensive workloads that can tolerate interruptions |
| Dedicated Hosts | Varies | Entire physical server reserved for you, with control over instance placement |
| Dedicated Instances | Varies | Instances running on hardware not shared with other customers |
| Capacity Reservations | Any duration | Reserved capacity within a specific Availability Zone |

### Placement Groups  
## EC2 Placement Groups

An **EC2 Placement Group** lets you control how EC2 instances are physically placed within the AWS infrastructure.

AWS provides three placement strategies:

| Strategy | Instance Placement | Main Objective | Common Use Cases |
|---|---|---|---|
| **Cluster** | Instances are placed close together within a single Availability Zone | High network performance and low latency | HPC, distributed processing, big data |
| **Spread** | Instances are placed on separate physical hardware | Minimize simultaneous hardware failures | Small number of critical instances |
| **Partition** | Instances are distributed across independent groups of racks | Isolate failures while supporting many instances | Hadoop, Cassandra, Kafka |

### Cluster Placement Group

Instances are placed physically close together within a **single Availability Zone**.

**Advantages:**

- Low network latency
- High network throughput
- Fast communication between instances

**Disadvantages:**

- A major failure within the Availability Zone may affect all instances
- Adding new instances can fail if AWS does not have enough capacity nearby

**Best for:** workloads where network performance is the priority.

## Spread Placement Group

Each instance is placed on **separate physical hardware** to reduce correlated hardware failures.

**Advantages:**

- Strong hardware failure isolation
- A hardware failure should not affect multiple instances in the group

**Limit:**

- Maximum of **7 running instances per Availability Zone per placement group**

**Best for:** a small number of critical instances that must run independently.

## Partition Placement Group

Instances are distributed across multiple **partitions**. Each partition uses a separate set of racks with independent power and networking.

**Advantages:**

- Supports hundreds of EC2 instances
- Limits the impact of hardware failures
- Applications can distribute data replicas across different partitions

**Best for:** large distributed systems such as **Hadoop, Cassandra, and Kafka**.

## Summary

- **Cluster:** instances close together → highest network performance
- **Spread:** instances on separate hardware → strongest instance-level isolation
- **Partition:** instances separated into groups of racks → suitable for large distributed systems

> **Note:** A Placement Group does not replace a Multi-AZ architecture. Cluster and Partition Placement Groups operate within one Availability Zone, while a Spread Placement Group can span multiple Availability Zones within the same AWS Region.  

### Elastic Network Interface (ENI)

An **Elastic Network Interface (ENI)** is a virtual network card that can be attached to an EC2 instance.

Like a physical network card, an ENI allows an EC2 instance to communicate with other resources and networks.

An ENI can include:

- A primary private IPv4 address
- One or more secondary private IPv4 addresses
- IPv6 addresses
- An associated public IPv4 address or Elastic IP
- A MAC address
- One or more Security Groups
- Network configuration information

## Why Did AWS Create ENIs?

AWS created ENIs to separate an EC2 instance's **computing resources** from its **network identity**.


EC2 instance → Computing resourcesS
ENI          → Network identity and configuration  
  
### EC2 Hibernation

**EC2 hibernation** lets you pause an EC2 instance while preserving the contents of its memory (**RAM**).

When the instance starts again, the operating system and applications resume from their previous state, similar to hibernating a laptop.

## How It Works

When an EC2 instance is hibernated:

1. AWS saves the contents of the RAM to the root EBS volume.
2. The EC2 instance is stopped.
3. The CPU and RAM resources are released.
4. When the instance starts again, AWS restores the saved RAM.
5. The operating system and applications resume from their previous state.
Running instance
       │
       ▼
RAM saved to EBS
       │
       ▼
Instance stopped
       │
       ▼
Instance started
       │
       ▼
RAM restored and applications resumed

## EC2 Hibernation Requirements and Limitations

- **Supported instance families:** C3, C4, C5, I3, M3, M4, R3, R4, T2, T3, etc.
- **Instance RAM size:** Must be less than 150 GB.
- **Instance size:** Bare metal instances are not supported.
- **AMI:** Amazon Linux 2, Linux AMI, Ubuntu, RHEL, CentOS, Windows, etc.
- **Root volume:**
  - Must be an EBS volume
  - Must be encrypted
  - Cannot be an Instance Store volume
  - Must be large enough to store the RAM contents
- Available for **On-Demand**, **Reserved**, and **Spot Instances**.
- An instance cannot remain hibernated for more than **60 days**.

### Load Balancing : 
## Health cheks : 
- the health check is one on a port and a route (/health is common)
## AWS Elastic Load Balancers

AWS provides four types of managed load balancers:

| Load Balancer | Abbreviation | Generation | OSI Layer | Supported Protocols | Main Use Case |
|---|---|---|---|---|---|
| Classic Load Balancer | CLB | Previous generation (2009) | Layer 4 and Layer 7 | HTTP, HTTPS, TCP, SSL/TLS | Legacy applications |
| Application Load Balancer | ALB | Second generation (2016) | Layer 7 — Application | HTTP, HTTPS, WebSocket | Web applications, APIs, microservices and container-based applications |
| Network Load Balancer | NLB | Second generation (2017) | Layer 4 — Transport | TCP, TLS, UDP, TCP_UDP | High-performance and low-latency network traffic |
| Gateway Load Balancer | GWLB | Current generation (2020) | Layer 3 — Network | IP packets using GENEVE | Firewalls, intrusion detection systems and other virtual network appliances |

## Classic Load Balancer (CLB)

- Introduced in **2009**
- Operates at both **Layer 4** and **Layer 7**
- Supports HTTP, HTTPS, TCP and SSL/TLS
- Considered the previous generation of AWS load balancers
- Mainly used for legacy applications

## Application Load Balancer (ALB)

- Introduced in **2016**
- Operates at **Layer 7 — Application layer**
- Supports HTTP, HTTPS and WebSocket
- Can route requests based on:
  - Hostname
  - URL path
  - HTTP headers
  - HTTP methods
  - Query parameters
  - Source IP address
- Recommended for web applications, APIs, microservices and containers

## Network Load Balancer (NLB)

- Introduced in **2017**
- Operates at **Layer 4 — Transport layer**
- Supports TCP, TLS, UDP and TCP_UDP
- Designed for:
  - Very high performance
  - Low latency
  - Large numbers of simultaneous connections
  - Static IP addresses

## Gateway Load Balancer (GWLB)

- Introduced in **2020**
- Operates at **Layer 3 — Network layer**
- Handles IP traffic
- Uses the **GENEVE** protocol to communicate with virtual appliances
- Designed for:
  - Firewalls
  - Intrusion detection and prevention systems
  - Deep packet inspection systems
  - Other third-party virtual network appliances

## Internal and Internet-Facing Load Balancers

Some AWS load balancers can be configured as:

- **Internet-facing:** Accessible from the internet
- **Internal:** Accessible only from private networks, such as a VPC

## Recommendation

For new applications, use the newer-generation load balancers:

- Use an **ALB** for HTTP/HTTPS applications and advanced request routing
- Use an **NLB** for high-performance TCP, TLS or UDP traffic
- Use a **GWLB** to deploy and scale virtual network appliances
- Use a **CLB** mainly for existing legacy applications

### Sticky Sessions (Session Affinity)  
- it is possible to implement stickness so that the same client is always redirected to the same instance bhind a load balancer. 
- This works for CLB and ALB. 
- THe "cookie" used for stickness has an expiration date you control 
- use case : make sure the user doesn't lose his session data. 
- Enabling stikness may bring imbalance to the load over the backend EC2 instances. 


## Load Balancer Sticky Session Cookies

### Application-Based Cookies

Application-based stickiness supports two types of cookies.

#### Custom Cookie

- Generated by the target application
- Can contain any custom attributes required by the application
- The cookie name must be specified individually for each target group
- Do not use the following reserved cookie names:
  - `AWSALB`
  - `AWSALBAPP`
  - `AWSALBTG`

> These cookie names are reserved for use by Elastic Load Balancing.

#### Application Cookie

- Generated by the load balancer
- The cookie name is `AWSALBAPP`

### Duration-Based Cookies

- Generated by the load balancer
- Cookie names:
  - `AWSALB` for an Application Load Balancer (ALB)
  - `AWSELB` for a Classic Load Balancer (CLB)

## Cross-Zone Load Balancing

### Application Load Balancer (ALB)

- Cross-zone load balancing is **enabled by default**
- It can be disabled at the **target group level**
- There are no charges for inter-Availability Zone data transfers

### Network Load Balancer (NLB) and Gateway Load Balancer (GWLB)

- Cross-zone load balancing is **disabled by default**
- It can be enabled
- Inter-Availability Zone data transfer charges apply when it is enabled

### Classic Load Balancer (CLB)

- Cross-zone load balancing is **disabled by default**
- It can be enabled
- There are no charges for inter-Availability Zone data transfers when it is enabled

## SSL/TLS Basics

- An SSL/TLS certificate encrypts traffic in transit between clients and the load balancer.
- **SSL** stands for **Secure Sockets Layer** and was created to encrypt network connections.
- **TLS** stands for **Transport Layer Security** and is the newer, more secure replacement for SSL.
- TLS certificates are used today, although they are still commonly called SSL certificates.
- Public SSL/TLS certificates are issued by trusted **Certificate Authorities (CAs)**.
- Examples of Certificate Authorities include:
  - Comodo
  - DigiCert
  - GlobalSign
  - GoDaddy
  - Let's Encrypt
  - Symantec
- SSL/TLS certificates have an expiration date and must be renewed.

## Load Balancer SSL/TLS Certificates

- The load balancer uses an **X.509 certificate**, also known as an SSL/TLS server certificate.
- Certificates can be created and managed using **AWS Certificate Manager (ACM)**.
- Alternatively, you can upload your own certificates.

## HTTPS Listener

When configuring an HTTPS listener:

- You must specify a default certificate.
- You can add an optional certificate list to support multiple domains.
- Clients can use **Server Name Indication (SNI)** to specify the hostname they want to access.
- You can select a security policy that defines:
  - Supported SSL/TLS protocol versions
  - Supported encryption algorithms and cipher suites
  - Compatibility with legacy clients

## TLS Termination

The load balancer can terminate the HTTPS connection:

Users
  │
  │ HTTPS — encrypted over the internet
  ▼
Load Balancer
  │
  │ HTTP over the private VPC
  ▼
EC2 Instance

## SSL Server Name Indication (SNI)

**Server Name Indication (SNI)** allows multiple SSL/TLS certificates to be used on the same web server or load balancer.

This makes it possible to host multiple HTTPS websites using the same endpoint.

## How SNI Works

1. The client starts an SSL/TLS handshake.
2. During the handshake, the client sends the hostname it wants to access.
3. The server or load balancer searches for the certificate associated with that hostname.
4. The correct certificate is returned to the client.
5. If no matching certificate is found, the default certificate is returned.

Client
  │
  │ Requested hostname: www.mycorp.com
  ▼
Load Balancer
  │
  ├── www.mycorp.com → Certificate A
  ├── api.mycorp.com → Certificate B
  └── No match       → Default certificate

## Connection Draining

**Connection Draining** allows an EC2 instance to be removed from a load balancer without immediately interrupting its active requests.

AWS uses different names depending on the type of load balancer:

- **Connection Draining** for Classic Load Balancer (CLB)
- **Deregistration Delay** for target groups used by Application Load Balancer (ALB) and Network Load Balancer (NLB)

## How It Works

When an instance begins deregistering:

1. The load balancer stops sending new requests to the instance.
2. Existing in-flight requests are allowed to complete.
3. New requests are sent to other healthy targets.
4. The load balancer waits until the active requests finish or the configured timeout expires.
5. The instance is then removed from the load balancer.

                        ┌── New requests ──────→ EC2-B
Client → Load Balancer ─┤
                        └── Existing requests ─→ EC2-A
                                                │
                                           Finish processing
                                                │
                                           Deregistered

## Auto Scaling Group Attributes

An Auto Scaling Group (ASG) includes the following main attributes.

### Launch Template

> Older Launch Configurations are deprecated. Launch Templates should be used instead.

A Launch Template can define:

- Amazon Machine Image (AMI)
- EC2 instance type
- EC2 User Data
- EBS volumes
- Security Groups
- SSH key pair
- IAM role for the EC2 instances
- Network and subnet configuration
- Load balancer information

### Capacity Configuration

An Auto Scaling Group defines three capacity values:

- **Minimum capacity:** The smallest number of instances the ASG can maintain
- **Maximum capacity:** The largest number of instances the ASG can launch
- **Desired capacity:** The initial or current number of instances the ASG attempts to maintain

Minimum capacity ≤ Desired capacity ≤ Maximum capacity


## Auto Scaling with CloudWatch Alarms

An Auto Scaling Group (ASG) can automatically scale based on Amazon CloudWatch alarms.

## How It Works

1. CloudWatch monitors a metric.
2. The metric is compared with a configured threshold.
3. When the threshold is crossed, the CloudWatch alarm changes state.
4. The alarm triggers an Auto Scaling policy.
5. The Auto Scaling Group adds or removes EC2 instances.

CloudWatch Metric
       │
       ▼
CloudWatch Alarm
       │
       ▼
Scaling Policy
       │
       ▼
Auto Scaling Group
       │
       ├── Scale out → Add EC2 instances
       └── Scale in  → Remove EC2 instances

### Auto Scaling Groups – Dynamic Scaling Policies
- Target Tracking Scaling
  Most simple and easy to set-up
Example: I want the average ASG CPU to stay at around 40%
- Simple / Step Scaling
When a CloudWatch alarm is triggered (example CPU > 70%), then add 2 units
When a CloudWatch alarm is triggered (example CPU < 30%), then remove 1
- Scheduled Actions
Anticipate a scaling based on known usage patterns
Example: increase the min capacity to 10 at 5 pm on Fridays
- predictive scaling 
  predictive Scaling: continuously forcast load and schedule scaling ahead  
### Good Metrics to Scale On
- CPUUtilization: Average CPU utilization across your instances
- RequestCountPerTarget: To make sure the number of requests per EC2 instance is stable
- Average Network In / Out (if your application is network bound)
- Any custom metric (that you push using CloudWatch)
### Auto Scaling Groups - Scaling Cooldowns
- After a scaling activity happens, you are in the cooldown period (default 300 seconds)
- During the cooldown period, the ASG will not launch or terminate additional instances (to allow for metrics to stabilize)
- Advice: Use a ready-to-use AMI to reduce configuration time in order to be serving requests faster and reduce the cooldown period
### AWS Global Infrastructure 
## CloudFront 
- Content Delivery Network (CDN)
- Improves read performance, content is cached at the edge
- Improves users experience
- 216 Point of Presence globally (edge locations)
- DDoS protection (because worldwide), integration with Shield, AWS Web Application Firewall
## CloudFront – Origins
- S3 Bucket
- For distributing files and caching them at the edge
- Enhanced security with CloudFront Origin Access Control (OAC)
- OAC is replacing Origin Access Identity (OAI)
- CloudFront can be used as an ingress (to upload files to S3)
- Custom Origin (HTTP)
- Application Load Balancer
- EC2 instance
- S3 website (must first enable the bucket as a static S3 website)
- Any HTTP backend you want

## CloudFront vs S3 Cross Region Replication
- CloudFront
- Global Edge network
- Files are cached for a TTL (maybe a day)
- Great for static content that must be available everywhere
- S3 Cross Region Replication
- Must be setup for each region you want replication to happen
- Files are updated in near real-time
- Read only
- Great for dynamic content that needs to be available at low-latency in few regions

## CloudFront Geo Restriction
- You can restrict who can access your distribution
- Allowlist: Allow your users to access your content only if they're in one of the countries on a list of approved countries.
- Blocklist: Prevent your users from accessing your content if they're in one of the countries on a list of banned countries.
- The “country” is determined using a 3rd party Geo-IP database
- Use case: Copyright Laws to control access to content
## CloudFront – Price Classes
- You can reduce the number of edge locations for cost reduction
- Three price classes:
- Price Class All: all regions – best performance
- Price Class 200: most regions, but excludes the most expensive regions
- Price Class 100: only the least expensive regions
## CloudFront – Cache Invalidations
- In case you update the back-end origin, CloudFront doesn’t know about it and will only get the refreshed content after the TTL has expired
- However, you can force an entire or partial cache refresh (thus bypassing the TTL) by performing a CloudFront Invalidation
- You can invalidate all files (*) or a special path (/images/*)
## Unicast IP vs Anycast IP
- Unicast IP: one server holds one IP address
- Anycast IP: all servers hold the same IP address and the client is routed to the nearest one
### AWS Global Accelerator
- Leverage the AWS internal network to route to your application
- 2 Anycast IP are created for your application
- The Anycast IP send traffic directly to Edge Locations
- The Edge Locations send the traffic to your application
- Works with Elastic IP, EC2 instances, ALB, NLB, public or private
- Consistent Performance
- Intelligent routing to lowest latency and fast regional failover
- No issue with client cache (because the IP doesn’t change)
- Internal AWS network
- Health Checks
- Global Accelerator performs a health check of your applications
- Helps make your application global (failover less than 1 minute for unhealthy)
- Great for disaster recovery (thanks to the health checks)
- Security
- Only 2 external IP need to be whitelisted
- DDoS protection thanks to AWS Shield
### AWS Global Accelerator vs CloudFront
- They both use the AWS global network and its edge locations around the world
- Both services integrate with AWS Shield for DDoS protection
## CloudFront
- Improves performance for both cacheable content (such as images and videos)
- Dynamic content (such as API acceleration and dynamic site delivery)
- Content is served at the edge
## Global Accelerator
- Improves performance for a wide range of applications over TCP or UDP
- Proxying packets at the edge to applications running in one or more AWS Regions
- Good fit for non-HTTP use cases, such as gaming (UDP), IoT (MQTT), or Voice over IP
- Good for HTTP use cases that require static IP addresses
- Good for HTTP use cases that require deterministic, fast regional failover
### AWS Lambda Integrations important : 
- API Gateway 
- Kinesis 
- DynamoDB 
- S3 
- CloudFront 
- CloudWatch Events EventBridge 
- CloudWatch Logs 
- SNS 
- SQS 
- Cognito 
### AWS Lambda Limits to Know – per Region
- Execution
  - Memory allocation: 128 MB – 10 GB (1 MB increments)
  - Maximum execution time: 900 seconds (15 minutes)
  - Environment variables: 4 KB
  - Disk capacity in the “function container” (in /tmp): 512 MB to 10 GB
  - Concurrency executions: 1000 (can be increased)
- Deployment
  - Lambda function deployment size (compressed .zip): 50 MB
  - Size of uncompressed deployment (code + dependencies): 250 MB
  - Can use the /tmp directory to load other files at startup
  - Size of environment variables: 4 KB

### Customization At The Edge
- Many modern applications execute some form of the logic at the edge
- Edge Function:
  - A code that you write and attach to CloudFront distributions
  - Runs close to your users to minimize latency
- CloudFront provides two types: CloudFront Functions & Lambda@Edge
- You don’t have to manage any servers, deployed globally
- Use case: customize the CDN content
- Pay only for what you use
- Fully serverless
### CloudFront Functions & Lambda@Edge Use Case
- Website Security and Privacy
- Dynamic Web Application at the Edge
- Search Engine Optimization (SEO)
- Intelligently Route Across Origins and Data Centers
- Bot Mitigation at the Edge
- Real-time Image Transformation
- A/B Testing
- User Authentication and Authorization
- User Prioritization
- User Tracking and Analytics
### CloudFront Functions
- Lightweight functions written in JavaScript
- For high-scale, latency-sensitive CDN customizations
- Sub-ms startup times, millions of requests/second
- Used to change Viewer requests and responses:
  - Viewer Request: after CloudFront receives a request from a viewer
  - Viewer Response: before CloudFront forwards the response to the viewer
- Native feature of CloudFront (manage code entirely within CloudFront)
### Lambda@Edge
- Lambda functions written in NodeJS or Python
- Scales to 1000s of requests/second
- Used to change CloudFront requests and responses:
  - Viewer Request – after CloudFront receives a request from a viewer
  - Origin Request – before CloudFront forwards the request to the Origin
  - Origin Response – after CloudFront receives the response from the origin
  - Viewer Response – before CloudFront forwards the response to the viewer
- Author your functions in one AWS Region (us-east-1), then CloudFront replicates to its locations

### CloudFront Functions vs. Lambda@Edge
| Feature                                | CloudFront Functions                      | Lambda@Edge                                      |
| -------------------------------------- | ----------------------------------------- | ------------------------------------------------ |
| **Runtime Support**                    | JavaScript                                | Node.js, Python                                  |
| **# of Requests**                      | Millions of requests per second           | Thousands of requests per second                 |
| **CloudFront Triggers**                | Viewer Request/Response                   | Viewer Request/Response, Origin Request/Response |
| **Max. Execution Time**                | < 1 ms                                    | 5–10 seconds                                     |
| **Max. Memory**                        | 2 MB                                      | 128 MB up to 10 GB                               |
| **Total Package Size**                 | 10 KB                                     | 1 MB – 50 MB                                     |
| **Network Access, File System Access** | No                                        | Yes                                              |
| **Access to the Request Body**         | No                                        | Yes                                              |
| **Pricing**                            | Free tier available, 1/6th price of @Edge | No free tier, charged per request & duration     |
## CloudFront Functions
- Cache key normalization
  - Transform request attributes (headers, cookies, query strings, URL) to create an optimal Cache Key
  - Header manipulation
    - Insert/modify/delete HTTP headers in the request or response
  - URL rewrites or redirects
  - Request authentication & authorization
    -Create and validate user-generated tokens (e.g., JWT) to allow/deny requests
## Lambda@Edge
- Longer execution time (several ms)
- Adjustable CPU or memory
- Your code depends on 3rd libraries (e.g., AWS SDK to access other AWS services)
- Network access to use external services for processing
- File system access or access to the body of HTTP requests
## Lambda in VPC 
- You must define the VPC ID, the Subnets and the Security Groups.
- Lambda will create an ENI (Elastic Network Interface) in your subnets. 
## Lambda with RDS Proxy
- If Lambda functions directly access your database, they may open too many connections under high load
- RDS Proxy
  - Improve scalability by pooling and sharing DB connections
  - Improve availability by reducing by 66% the failover time and preserving connections
  - Improve security by enforcing IAM authentication and storing credentials in Secrets Manager
- The Lambda function must be deployed in your VPC, because RDS Proxy is never publicly accessible
## Amazon DynamoDB
- Fully managed, highly available with replication across multiple AZs
- NoSQL database – not a relational database – with transaction support
- Scales to massive workloads, distributed database
- Millions of requests per seconds, trillions of row, 100s of TB of storage
- Fast and consistent in performance (single-digit millisecond)
- Integrated with IAM for security, authorization and administration
- Low cost and auto-scaling capabilities
- No maintenance or patching, always available
- Standard & Infrequent Access (IA) Table Class
 ## DynamoDB – Basics
- DynamoDB is made of Tables
- Each table has a Primary Key (must be decided at creation time)
- Each table can have an infinite number of items (= rows)
- Each item has attributes (can be added over time – can be null)
- Maximum size of an item is 400 KB
- Data types supported are:
  - Scalar Types – String, Number, Binary, Boolean, Null
  - Document Types – List, Map
  - Set Types – String Set, Number Set, Binary Set
- Therefore, in DynamoDB you can rapidly evolve schemas
## DynamoDB – Read/Write Capacity Modes
  - Control how you manage your table’s capacity (read/write throughput)
## Provisioned Mode (default)
- You specify the number of reads/writes per second
- You need to plan capacity beforehand
- Pay for provisioned Read Capacity Units (RCU) & Write Capacity Units (WCU)
- Possibility to add auto-scaling mode for RCU & WCU
## On-Demand Mode
- Read/writes automatically scale up/down with your workloads
- No capacity planning needed
- Pay for what you use, more expensive ($$$)
- Great for unpredictable workloads, steep sudden spikes
## DynamoDB Accelerator (DAX)
- Fully-managed, highly available, seamless in-memory cache for DynamoDB
- Help solve read congestion by caching
- Microseconds latency for cached data
- Doesn’t require application logic modification (compatible with existing DynamoDB APIs)
- 5 minutes TTL for cache (default)
### DynamoDB – Stream Processing
- Ordered stream of item-level modifications (create/update/delete) in a table
- Use cases:
  - React to changes in real-time (welcome email to users)
  - Real-time usage analytics
  - Insert into derivative tables
  - Implement cross-region replication
  - Invoke AWS Lambda on changes to your DynamoDB table
## DynamoDB Streams
- 24 hours retention
- Limited # of consumers
- Process using AWS Lambda Triggers, or DynamoDB Stream Kinesis adapter
## Kinesis Data Streams (newer)
- 1 year retention
- High # of consumers
- Process using AWS Lambda, Kinesis Data Analytics, Kinesis Data Firehose, AWS Glue Streaming ETL...
## DynamoDB Global Tables
- Make a DynamoDB table accessible with low latency in multiple regions
- Active-Active replication
- Applications can READ and WRITE to the table in any region
- Must enable DynamoDB Streams as a pre-requisite
## DynamoDB – Time To Live (TTL)
- Automatically delete items after an expiry timestamp
- Use cases: reduce stored data by keeping only current items, adhere to regulatory obligations, web session handling... 
## DynamoDB – Backups for Disaster Recovery
- Continuous backups using point-in-time recovery (PITR)
  - Optionally enabled for the last 35 days
  - Point-in-time recovery to any time within the backup window
  - The recovery process creates a new table
- On-demand backups
  - Full backups for long-term retention, until explicitly deleted
  - Doesn’t affect performance or latency
  - Can be configured and managed in AWS Backup (enables cross-region copy)
  - The recovery process creates a new table
  ## DynamoDB – Integration with Amazon S3
- Export to S3 (must enable PITR)
  - Works for any point of time in the last 35 days
  - Doesn’t affect the read capacity of your table
  - Perform data analysis on top of DynamoDB
  - Retain snapshots for auditing
  - ETL on top of S3 data before importing back into DynamoDB
  - Export in DynamoDB JSON or ION format
- Import to S3
  - Import CSV, DynamoDB JSON, or ION format
  - Doesn’t consume any write capacity
  - Creates a new table
  - Import errors are logged in CloudWatch Logs
## AWS API Gateway
- AWS Lambda + API Gateway: No infrastructure to manage
- Support for the WebSocket Protocol
- Handle API versioning (v1, v2...)
- Handle different environments (dev, test, prod...)
- Handle security (Authentication and Authorization)
- Create API keys, handle request throttling
- Swagger / OpenAPI import to quickly define APIs
- Transform and validate requests and responses
- Generate SDK and API specifications
- Cache API responses
## API Gateway – Integrations High Level
- Lambda Function
  - Invoke Lambda function
  - Easy way to expose REST API backed by AWS Lambda
- HTTP
  - Expose HTTP endpoints in the backend
  - Example: internal HTTP API on premise, Application Load Balancer...
  - Why? Add rate limiting, caching, user authentications, API keys, etc...
- AWS Service
  - Expose any AWS API through the API Gateway
  - Example: start an AWS Step Function workflow, post a message to SQS
  - Why? Add authentication, deploy publicly, rate control...
  ## API Gateway – Endpoint Types
- Edge-Optimized (default)
  - For global clients
  - Requests are routed through the CloudFront Edge locations (improves latency)
  - The API Gateway still lives in only one region
- Regional
  - For clients within the same region
  - Could manually combine with CloudFront (more control over the caching strategies and the distribution)
- Private
  - Can only be accessed from your VPC using an interface VPC endpoint (ENI)
  - Use a resource policy to define access
## API Gateway – Security
- User Authentication through
  - IAM Roles (useful for internal applications)
  - Cognito (identity for external users – example mobile users)
  - Custom Authorizer (your own logic)
- Custom Domain Name
  - HTTPS security through integration with AWS Certificate Manager (ACM)
  - If using Edge-Optimized endpoint, then the certificate must be in us-east-1
  - If using Regional endpoint, the certificate must be in the API Gateway region
  - Must setup CNAME or A-alias record in Route 53
### Machine Learning in AWS 
## Amazon Rekognition
- Find objects, people, text, scenes in images and videos using ML
- Facial analysis and facial search to do user verification, people counting
- Create a database of “familiar faces” or compare against celebrities
- Use cases:
 - Labeling
  - Content Moderation
  - Text Detection
  - Face Detection and Analysis (gender, age range, emotions...)
  - Face Search and Verification
  - Celebrity Recognition
  - Pathing (ex: for sports game analysis)
## Amazon Transcribe
- Automatically convert speech to text
- Uses a deep learning process called Automatic Speech Recognition (ASR) to convert speech to text quickly and accurately
- Automatically remove Personally Identifiable Information (PII) using Redaction
- Supports Automatic Language Identification for multi-lingual audio
- Use cases:
  - Transcribe customer service calls
  - Automate closed captioning and subtitling
  - Generate metadata for media assets to create a fully searchable archive
## Amazon Polly
- Turn text into lifelike speech using deep learning
- Allowing you to create applications that talk
## Amazon Polly – Lexicon & SSML
- Customize the pronunciation of words with Pronunciation lexicons
- Stylized words: St3ph4ne => “Stephane”
- Acronyms: AWS => “Amazon Web Services”
- Upload the lexicons and use them in the SynthesizeSpeech operation
- Generate speech from plain text or from documents marked up with Speech Synthesis Markup Language (SSML) – enables more customization:
- Emphasizing specific words or phrases
- Using phonetic pronunciation
- Including breathing sounds, whispering
- Using the Newscaster speaking style
## Amazon Translate
- Natural and accurate language translation
- Amazon Translate allows you to localize content – such as websites and applications – for international users, and to easily translate large volumes of text efficiently
## Amazon Lex & Connect
- Amazon Lex
  - Same technology that powers Alexa
  - Automatic Speech Recognition (ASR) to convert speech to text
  - Natural Language Understanding to recognize the intent of text, callers
  - Helps build chatbots, call center bots
- Amazon Connect
  - Receive calls, create contact flows, cloud-based virtual contact center
  - Can integrate with other CRM systems or AWS
  - No upfront payments, 80% cheaper than traditional contact center solutions 

## Amazon Comprehend
- For Natural Language Processing (NLP)
- Fully managed and serverless service
- Uses machine learning to find insights and relationships in text
- Detects the language of the text
- Extracts key phrases, places, people, brands, or events
- Understands how positive or negative the text is
- Analyzes text using tokenization and parts of speech
- Automatically organizes a collection of text files by topic
- Sample use cases:
- Analyze customer interactions (emails) to find what leads to a positive or negative experience
- Create and group articles by topics that Comprehend will uncover
## Amazon Comprehend Medical
- Amazon Comprehend Medical detects and returns useful information in unstructured clinical text:
  - Physician’s notes
  - Discharge summaries
  - Test results
  - Case notes
- Uses NLP to detect Protected Health Information (PHI) – DetectPHI API
- Store your documents in Amazon S3, analyze real-time data with Kinesis Data Firehose, or use Amazon Transcribe to transcribe patient narratives into text that can be analyzed by Amazon Comprehend Medical.
## Amazon SageMaker
- Fully managed service for developers / data scientists to build ML models
- Typically, difficult to do all the processes in one place + provision servers
- Machine learning process (simplified): predicting your exam score
  - Start with historical data
  - Label the data with scores
  - Build the ML model
  - Train and tune the model
  - Apply the model to new data
  - Generate a prediction
## Amazon Forecast
- Fully managed service that uses ML to deliver highly accurate forecasts
- Example: predict the future sales of a raincoat
- 50% more accurate than looking at the data itself
- Reduce forecasting time from months to hours
- Use cases: Product Demand Planning, Financial Planning, Resource Planning, ...
## Amazon Kendra
- Fully managed document search service powered by Machine Learning
- Extract answers from within a document (text, PDF, HTML, PowerPoint, MS Word, FAQs...)
- Natural language search capabilities
- Learn from user interactions/feedback to promote preferred results (Incremental Learning)
- Ability to manually fine-tune search results (importance of data, freshness, custom, ...)
## Amazon Personalize
- Fully managed ML-service to build apps with real-time personalized recommendations
- Example: personalized product recommendations/re-ranking, customized direct marketing
- Example: User bought gardening tools, provide recommendations on the next one to buy
- Same technology used by Amazon.com
- Integrates into existing websites, applications, SMS, email marketing systems, ...
- Implement in days, not months (you don’t need to build, train, and deploy ML solutions)
- Use cases: retail stores, media and entertainment...
## Amazon Textract
- Automatically extracts text, handwriting, and data from any scanned documents using AI and ML
- Extract data from forms and tables
- Read and process any type of document (PDFs, images, ...)
- Use cases:
  - Financial Services (e.g., invoices, financial reports)
  - Healthcare (e.g., medical records, insurance claims)
  - Public Sector (e.g., tax forms, ID documents, passports) 
### AWS Machine Learning – Summary
- Rekognition: face detection, labeling, celebrity recognition
- Transcribe: audio to text (ex: subtitles)
- Polly: text to audio
- Translate: translations
- Lex: build conversational bots – chatbots
- Connect: cloud contact center
- Comprehend: natural language processing
- SageMaker: machine learning for every developer and data scientist
- Forecast: build highly accurate forecasts
- Kendra: ML-powered search engine
- Personalize: real-time personalized recommendations
- Textract: detect text and data in documents
## Amazon ECS – EC2 Launch Type
- ECS = Elastic Container Service
- Launch Docker containers on AWS = Launch ECS Tasks on ECS Clusters
- EC2 Launch Type: you must provision & maintain the infrastructure (the EC2 instances)
- Each EC2 Instance must run the ECS Agent to register in the ECS Cluster
- AWS takes care of starting / stopping containers
## Amazon ECS – Fargate Launch Type
- Launch Docker containers on AWS
- You do not provision the infrastructure (no EC2 instances to manage)
- It’s all Serverless!
- You just create task definitions
- AWS just runs ECS Tasks for you based on the CPU / RAM you need
- To scale, just increase the number of tasks. Simple – no more EC2 instances
## Amazon ECS – IAM Roles for ECS
- EC2 Instance Profile (EC2 Launch Type only)
  - Used by the ECS agent
  - Makes API calls to ECS service
  - Send container logs to CloudWatch Logs
  - Pull Docker image from ECR
  - Reference sensitive data in Secrets Manager or SSM Parameter Store
- ECS Task Role
  - Allows each task to have a specific role
  - Use different roles for the different ECS Services you run
  - Task Role is defined in the task definition
## Amazon ECR
- ECR = Elastic Container Registry
- Store and manage Docker images on AWS
- Private and Public repository (Amazon ECR Public Gallery)
- Fully integrated with ECS, backed by Amazon S3
- Access is controlled through IAM (permission errors => policy)
- Supports image vulnerability scanning, versioning, image tags, image lifecycle, ...
### Amazon S3
### Amazon S3 Use Cases 
- backup and storage 
- disaster Recovery 
- Archive 
- Hybrid Cloud Storage 
- Application Hosting 
- Media Hosting 
- Data lakes & big data analytics 
- Software delivery 
- Static website 
## Amazon S3 - Buckets
- Amazon S3 allows people to store objects (files) in “buckets” (directories)
- Buckets must have a globally unique name (across all regions, all accounts)
- Buckets are defined at the region level
- S3 looks like a global service, but buckets are created in a region
- ***Naming Convention***
- No uppercase, no underscore
- 3–63 characters long
- Not an IP
- Must start with a lowercase letter or number
- Must NOT start with the prefix xn--
- Must NOT end with the suffix -s3alias
## Amazon S3 - Objects
- Objects (files) have a Key
- The key is the FULL path:
  - s3://my-bucket/my_file.txt
  - s3://my-bucket/my_folder1/another_folder/my_file.txt
- The key is composed of prefix + object name
  - s3://my-bucket/my_folder1/another_folder/my_file.txt
- There’s no concept of “directories” within buckets (although the UI will trick you to think otherwise)
- Just keys with very long names that contain slashes (/)
## Amazon S3 - Security
- User-Based
  - IAM Policies – which API calls should be allowed for a specific user from IAM
- Resource-Based
  - Bucket Policies – bucket-wide rules from the S3 console; allows cross-account access
  - Object Access Control List (ACL) – finer grain (can be disabled)
  - Bucket Access Control List (ACL) – less common (can be disabled)
- Note: An IAM principal can access an S3 object if:
  - The user IAM permissions ALLOW it OR the resource policy ALLOWS it
  - AND there’s no explicit DENY
- Encryption: Encrypt objects in Amazon S3 using encryption keys
## Amazon S3 – Bucket Policies
- JSON-based policies
  - Resources: buckets and objects
  - Effect: Allow / Deny
  - Actions: Set of APIs to Allow or Deny
  - Principal: The account or user to apply the policy to
- Use S3 bucket policies to:
  - Grant public access to the bucket
  - Force objects to be encrypted at upload
  - Grant access to another account (Cross-Account)
## Bucket Settings for Block Public Access
- Block all public access: On
  - Block public access to buckets and objects granted through new access control lists (ACLs)
  - Block public access to buckets and objects granted through any access control lists (ACLs)
  - Block public access to buckets and objects granted through new public bucket or access point policies
  - Block public and cross-account access to buckets and objects through any public bucket or access point policies
- These settings were created to prevent company data leaks
- If you know your bucket should never be public, leave these settings on
- Can be set at the account level
## Amazon S3 – Static Website Hosting
- S3 can host static websites and have them accessible on the Internet.
- The website URL will be (depending on the region):
- http://bucket-name.s3-website-aws-region.amazonaws.com
- OR
- http://bucket-name.s3-website.aws-region.amazonaws.com
- If you get a 403 Forbidden error, make sure the bucket policy allows public reads.
## Amazon S3 – Versioning
- You can version your files in Amazon S3.
- It is enabled at the bucket level.
- Same key overwrite will change the version: 1, 2, 3, ...
- It is best practice to version your buckets:
  - Protect against unintended deletes (ability to restore a version).
  - Easy rollback to a previous version.
- Notes:
  - Any file that is not versioned prior to enabling versioning will have version null.
  - Suspending versioning does not delete the previous versions.
## Amazon S3 – Replication (CRR & SRR)
- Must enable Versioning in source and destination buckets.
- Cross-Region Replication (CRR)
- Same-Region Replication (SRR)
- Buckets can be in different AWS accounts.
- Copying is asynchronous.
- Must give proper IAM permissions to S3.
- Use cases:
  - CRR – compliance, lower-latency access, replication across accounts.
  - SRR – log aggregation, live replication between production and test accounts. 
 ## Amazon S3 – Replication (Notes)
- After you enable Replication, only new objects are replicated.
- Optionally, you can replicate existing objects using S3 Batch Replication.
- S3 Batch Replication:
  - Replicates existing objects.
  - Replicates objects that previously failed replication.
- For DELETE operations:
  - Can replicate delete markers from source to target (optional setting).
  - Deletions with a version ID are not replicated (to avoid malicious deletes).
- There is no “chaining” of replication:
  - If Bucket 1 → Bucket 2 → Bucket 3
  - Objects originally created in Bucket 1 are not replicated from Bucket 2 to Bucket 3. 
  