> **Note:** This file is written in Markdown and is best viewed with a Markdown viewer (e.g., GitHub, GitLab, VS Code, or a dedicated Markdown reader). Viewing it in a plain text editor may not render the formatting as intended.

Copyright (c) 2025 Software Tree

# Gilhari Many-to-Many Example

> **Demonstrates many-to-many relationships between JSON objects with Gilhari ORM**

Gilhari is a Docker-compatible microservice framework that provides RESTful Object-Relational Mapping (ORM) functionality for JSON objects with any relational database.

Remarkably, Gilhari automates REST APIs (POST, GET, PUT, DELETE, etc.) handling, JSON CRUD operations, and database schema setup — **no manual coding required**.

## About This Example

This repository contains a standalone example showing how to configure Gilhari to handle many-to-many relationships between JSON objects using a join class pattern.

The example uses the base Gilhari docker image (softwaretree/gilhari) to easily create a new docker image (gilhari_manytomany_example) that can run as a RESTful microservice (server) to persist app specific JSON objects with relational mappings.

This example can be used **standalone as a RESTful microservice** or optionally with the ORMCP Server.

- **ORMCP Documentation**: [https://github.com/softwaretree/ormcp-docs](https://github.com/softwaretree/ormcp-docs)
- **ORMCP/Gilhari Examples**: [https://github.com/softwaretree/ormcp-docs#examples](https://github.com/softwaretree/ormcp-docs#examples) - Comprehensive list of examples

**Note:** This example is also included in the Gilhari SDK distribution. If you have the SDK installed, you can use it directly from the `examples/gilhari_manytomany_example` directory without cloning.

## Example Overview

The example showcases a JSON object model with three types of objects: **User**, **Group**, and **UserGroup**

**Object Model Overview:**
- **JSON_User**: User object with id and name
- **JSON_Group**: Group object with id and name
- **JSON_UserGroup**: Join class that materializes the many-to-many relationship
- **Attributes**: 
  - User: uId (int), uName (string), groups (array of Group objects)
  - Group: gId (int), gName (string), users (array of User objects)
  - UserGroup: uId (int), gId (int)
- **Database Tables**: USER, GRP, USER_GRP (join table)

### What Makes This Example Different?

This example demonstrates a **many-to-many relationship** pattern:

**Many-to-Many Relationship:**
- A **User object** can belong to many **Group objects** (one-to-many relationship from User's perspective)
- A **Group object** can have many **User objects** (one-to-many relationship from Group's perspective)
- **UserGroup object** serves as a join class to materialize the many-to-many relationship between User and Group
- The relationship is bidirectional - you can navigate from User to Groups and from Group to Users

**Configuration:**
See `config/gilhari_manytomany_example.jdx` for how to configure many-to-many relationships using join classes.

### User Object Structure
```json
{
  "uId": 1,
  "uName": "John Doe",
  "groups": [
    {
      "gId": 101,
      "gName": "Developers"
    },
    {
      "gId": 102,
      "gName": "Architects"
    }
  ]
}
```

### Group Object Structure
```json
{
  "gId": 101,
  "gName": "Developers",
  "users": [
    {
      "uId": 1,
      "uName": "John Doe"
    },
    {
      "uId": 2,
      "uName": "Jane Smith"
    }
  ]
}
```

### UserGroup (Join) Object Structure
```json
{
  "uId": 1,
  "gId": 101
}
```

**Note:** The UserGroup object represents the association/join between a User and a Group. It's automatically managed by Gilhari when you create relationships.

## Project Structure

```
gilhari_manytomany_example/
├── src/                           # Container domain model classes
│   └── com/softwaretree/...      # JSON_User.java, JSON_Group.java, JSON_UserGroup.java
├── config/                        # Configuration files
│   ├── gilhari_manytomany_example.jdx  # ORM specification with many-to-many relationships
│   └── classnames_map_example.js
├── bin/                           # Compiled .class files
├── Dockerfile                     # Docker image definition
├── gilhari_service.config         # Service configuration
├── compile.cmd / .sh              # Compilation scripts
├── build.cmd / .sh                # Docker build scripts
├── run_docker_app.cmd / .sh       # Docker run scripts
└── curlCommands.cmd / .sh         # API testing scripts
```

## Source Code
The `src` directory contains the declarations of the underlying shell (container) classes (e.g., JSON_User, JSON_Group, JSON_UserGroup) that are used to define the object-relational mapping (ORM) specification for the corresponding conceptual domain-specific JSON object model classes:

- **JSON_User, JSON_Group, and JSON_UserGroup classes**: Simple shell (container) classes (.java files) corresponding to the domain-specific JSON object model classes of related entities (Container domain model classes)
- **JDX_JSONObject**: Base class of the container domain model classes for handling persistence of domain-specific JSON objects
- **Container domain model classes**: Only need to define two constructors, with most processing handled by the JDX_JSONObject superclass

**Note:** Gilhari does not require any explicit programmatic definitions (e.g., ES6 style JavaScript classes) for domain-specific JSON object model classes. It handles the data of domain-specific JSON objects using instances of the container domain model classes and the ORM specification.

## Configurations

A declarative ORM specification for the domain-specific JSON object model classes and their attributes is defined in `config/gilhari_manytomany_example.jdx` using the container domain model classes. This file defines the mappings between JSON objects and database tables, **including the many-to-many relationship configuration**.

**Key points:**
- Update the database URL and JDBC driver in this file according to your setup
- See `JDX_DATABASE_JDBC_DRIVER_Specification_Guide` (.md or .html) for guides on configuring different databases
- The container domain model classes (like JSON_User, JSON_Group) corresponding to the conceptual domain-specific JSON object model classes are defined as subclasses of the JDX_JSONObject class
- Appropriate mappings for the domain-specific JSON object model classes are defined in the ORM specification file using the corresponding container domain model classes
- **Many-to-many relationship configuration** uses JOIN_COLLECTION_CLASS to define the associations through the join class

For comprehensive details on defining and using container classes and the ORM specification for JSON object models, refer to the **"Persisting JSON Objects"** section in the JDX User Manual.

### Many-to-Many Relationship Configuration

The key to this example is in the ORM specification file (`config/gilhari_manytomany_example.jdx`), where the many-to-many relationship is configured using a join class pattern.

**Join Class Definition:**
```
CLASS .JSON_UserGroup TABLE USER_GRP
    VIRTUAL_ATTRIB uId ATTRIB_TYPE int
    VIRTUAL_ATTRIB gId ATTRIB_TYPE int
    PRIMARY_KEY uId gId
;
```

**Join Collection for Users in a Group:**
```
JOIN_COLLECTION_CLASS ArrayUsers COLLECTION_TYPE ARRAY ELEMENT_CLASS .JSON_User JOIN_CLASS .JSON_UserGroup
   PRIMARY_KEY gId
   JOIN_KEY uId
;
```

**Join Collection for Groups for a User:**
```
JOIN_COLLECTION_CLASS ArrayGroups COLLECTION_TYPE ARRAY ELEMENT_CLASS .JSON_Group JOIN_CLASS .JSON_UserGroup
    PRIMARY_KEY uId
    JOIN_KEY gId
;
```

**Relationship in Group class:**
```
CLASS .JSON_Group TABLE GRP
    ...
    RELATIONSHIP users REFERENCES ArrayUsers BYVALUE WITH gId
;
```

**Relationship in User class:**
```
CLASS .JSON_User TABLE USER
    ...
    RELATIONSHIP groups REFERENCES ArrayGroups BYVALUE WITH uId
;
```

This configuration creates a bidirectional many-to-many relationship where:
- Users can have multiple Groups
- Groups can have multiple Users
- The UserGroup join table manages the associations

### Docker Configuration

The `Dockerfile` builds a RESTful Gilhari microservice using:
- Base Gilhari image (softwaretree/gilhari)
- Compiled domain model (.class) files
- Configuration files including the ORM specification and a JDBC driver

### Service Configuration

The `gilhari_service.config` file specifies runtime parameters for the RESTful Gilhari microservice:

```json
{
  "gilhari_microservice_name": "gilhari_manytomany_example",
  "jdx_orm_spec_file": "./config/gilhari_manytomany_example.jdx",
  "jdbc_driver_path": "/node/node_modules/jdxnode/external_libs/sqlite-jdbc-3.50.3.0.jar",
  "jdx_debug_level": 3,
  "jdx_force_create_schema": "true",
  "jdx_persistent_classes_location": "./bin",
  "classnames_map_file": "config/classnames_map_example.js",
  "gilhari_rest_server_port": 8081
}
```

#### Service Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gilhari_microservice_name` | Optional name to identify this Gilhari microservice. The name is logged on console during start up | - |
| `jdx_orm_spec_file` | Location of the ORM specification file containing mapping for persistent classes | - |
| `jdbc_driver_path` | Path to the JDBC driver (.jar) file. SQLite driver included by default | - |
| `jdx_debug_level` | Debug output level (0-5). 0 = most verbose, 5 = minimal. Level 3 outputs all SQL statements | 5 |
| `jdx_force_create_schema` | Whether to recreate database schema on each run. `true` = useful for development, `false` = create only once | false |
| `jdx_persistent_classes_location` | Root location for compiled persistent (Container domain model) classes. Can be a directory (e.g., ./bin) or a JAR file path. Used as a Java CLASSPATH  | - |
| `classnames_map_file` | Optional JSON file that can map names of container domain model classes to (simpler) object class (type) names (e.g., by omitting a package name) to simplify REST URL| - |
| `gilhari_rest_server_port` | Port number for the RESTful service. This port number may be mapped to different port number (e.g., 80) by a docker run command. | 8081 |


## Build Files
- `compile.cmd` / `compile.sh`: Compiles the container domain model classes
- `sources.txt`: Lists the names of the container domain model class source (.java) files for compilation
- `build.cmd` / `build.sh`: Creates the Gilhari Docker image (gilhari_manytomany_example) using the local Dockerfile

**Note**: Compilation targets JDK version 1.8, which is compatible with the current Gilhari version.

## Quick Start

### For Quick Evaluation (No SDK Required)
If you just want to see this example in action without modifications:

1. **Clone this repository** (pre-compiled classes included)
2. **Install Docker**
3. **Build and run** (skip compilation step)

### For Development and Customization
If you want to modify the object model or create your own Gilhari microservices:

1. **Gilhari SDK**: Download and install from [https://softwaretree.com](https://softwaretree.com)
2. **JX_HOME environment variable**: Set to the root directory of your Gilhari SDK installation
3. **Java Development Kit (JDK 1.8+)** for compilation
4. **Docker** installed on your system

**Note:** The Gilhari SDK contains necessary libraries (JARs) and base classes required for compiling container domain model classes. While pre-compiled `.class` files are included in this repository for immediate use, you'll need the SDK to make any modifications to the object model or to create your own Gilhari microservices.

## Build and Run

### Option 1: Quick Run (Using Pre-compiled Classes)

**Skip compilation** and go straight to Docker:

```bash
# Windows
build.cmd
run_docker_app.cmd

# Linux/Mac
./build.sh
./run_docker_app.sh
```

### Option 2: Compile and Run (For Modifications)

**If you've made changes to the source code:**

1. **Ensure JX_HOME is set** to your Gilhari SDK installation directory

2. **Compile the classes**:
   ```bash
   # Windows
   compile.cmd
   
   # Linux/Mac
   ./compile.sh
   ```

3. **Build and run the Docker container**:
   ```bash
   # Windows
   build.cmd
   run_docker_app.cmd
   
   # Linux/Mac
   ./build.sh
   ./run_docker_app.sh
   ```

## REST API Usage

Once running, access the Gilhari microservice at:

```
http://localhost:<port>/gilhari/v1/:className
```

**Example endpoints:**
```
http://localhost:80/gilhari/v1/User
http://localhost:80/gilhari/v1/Group
http://localhost:80/gilhari/v1/UserGroup
```

### Supported HTTP Methods

| Method | Purpose | Example |
|--------|---------|---------|
| GET | Retrieve objects | `GET /gilhari/v1/User` |
| POST | Create objects | `POST /gilhari/v1/User` |
| PUT | Update objects | `PUT /gilhari/v1/User` |
| PATCH | Partial update | `PATCH /gilhari/v1/User` |
| DELETE | Delete objects | `DELETE /gilhari/v1/User` |

### Example: Creating Users and Groups with Relationships

**Create a Group:**
```bash
curl -X POST http://localhost:80/gilhari/v1/Group \
  -H "Content-Type: application/json" \
  -d '{
    "gId": 101,
    "gName": "Developers"
  }'
```

**Create a User with Group membership:**
```bash
curl -X POST http://localhost:80/gilhari/v1/User \
  -H "Content-Type: application/json" \
  -d '{
    "uId": 1,
    "uName": "John Doe",
    "groups": [
      {
        "gId": 101,
        "gName": "Developers"
      }
    ]
  }'
```

**Get a User with all their Groups:**
```bash
curl -X GET "http://localhost:80/gilhari/v1/User/1" \
  -H "Content-Type: application/json"
```

**Get a Group with all its Users:**
```bash
curl -X GET "http://localhost:80/gilhari/v1/Group/101" \
  -H "Content-Type: application/json"
```

### Testing the API

**Comprehensive test scripts:**
- `curlCommands.cmd / .sh`: Extensive REST API test calls demonstrating many-to-many relationships

The `curlCommands` script provides a complete demonstration of many-to-many relationship operations:

- Creating Users and Groups independently
- Associating existing objects through the UserGroup join table
- Creating objects with relationships in a single operation
- Querying with and without referenced objects (`deep=true/false`)
- Using filters to query specific objects
- Aggregate operations (COUNT) on all object types
- Managing associations without affecting the related objects
- Proper cleanup operations

Run the script to generate a `curl.log` file with all responses:
```bash
# Windows
curlCommands.cmd

# Linux/Mac
chmod +x curlCommands.sh
./curlCommands.sh

# Custom port
curlCommands.cmd 8899
./curlCommands.sh 8899
```

**Other options:**
- **Postman**: Import the endpoints for interactive testing
- **Browser**: Access GET endpoints directly
- **Any REST Client**: Standard HTTP methods work with any REST client
- **ORMCP Server** (optional): Use ORMCP Server tools for AI-powered interactions

## Using with ORMCP Server (Optional)

This Gilhari microservice can be used with the ORMCP Server for AI-powered database interactions:

1. **Start this Gilhari microservice** (as shown in Quick Start)
2. **Configure ORMCP Server** to connect to this microservice endpoint
3. **Use ORMCP tools** to query and manipulate User, Group, and their relationships through natural language

The ORMCP Server will automatically handle the many-to-many relationship navigation and join operations.

For more information on ORMCP Server:
- **ORMCP Documentation**: [https://github.com/softwaretree/ormcp-docs](https://github.com/softwaretree/ormcp-docs)
- **ORMCP/Gilhari Examples**: [https://github.com/softwaretree/ormcp-docs#examples](https://github.com/softwaretree/ormcp-docs#examples)
- **Product Website**: [https://www.softwaretree.com/products/ormcp/](https://www.softwaretree.com/products/ormcp/)


## Development Tools

### Docker Container Access
Shell into a running container:
```bash
# Find container ID
docker ps

# Access container
docker exec -it <container-id> bash
```

### View Logs
```bash
docker logs <container-id>
```

### Stop Container
```bash
docker stop <container-id>
```

## Additional Resources

- **JDX User Manual**: "Persisting JSON Objects" section for detailed ORM specification documentation
- **Gilhari SDK Documentation**: The SDK available for download at [https://softwaretree.com](https://softwaretree.com)
- **ORMCP Documentation**: [https://github.com/softwaretree/ormcp-docs](https://github.com/softwaretree/ormcp-docs)
- **Database Configuration Guide**: See `JDX_DATABASE_JDBC_DRIVER_Specification_Guide.md`
- **operationDetails Documentation**: See `operationDetails_doc.md` for GraphQL-like query capabilities

## Platform Notes

Script files are provided for both Windows (`.cmd`) and Linux/Mac (`.sh`). 

**Linux/Mac users**: Make scripts executable before running:
```bash
chmod +x *.sh
```

## Troubleshooting

### Common Issues

**Problem**: Docker image build fails
- **Solution**: Ensure the base Gilhari image is pulled: `docker pull softwaretree/gilhari`

**Problem**: Compilation errors
- **Solution**: Verify JDK 1.8+ is installed and JX_HOME environment variable is set correctly

**Problem**: Port 80 already in use
- **Solution**: Modify `run_docker_app` script to use a different port (e.g., `-p 8080:8081`)

**Problem**: Database connection errors
- **Solution**: Check `config/gilhari_manytomany_example.jdx` for correct database URL and JDBC driver path

**Problem**: Relationships not working correctly
- **Solution**: Verify the ORM specification has proper JOIN_COLLECTION_CLASS definitions and RELATIONSHIP declarations for both sides of the many-to-many relationship

**Problem**: Circular reference issues when retrieving objects
- **Solution**: This is expected behavior in many-to-many relationships. Use query parameters or projections to control the depth of object retrieval

## Support

For issues or questions:
- **ORMCP Documentation & Issues**: [https://github.com/softwaretree/ormcp-docs/issues](https://github.com/softwaretree/ormcp-docs/issues)
- **This example**: [https://github.com/SoftwareTree/gilhari_manytomany_example/issues](https://github.com/SoftwareTree/gilhari_manytomany_example/issues)
- **Gilhari SDK**: Contact support at [gilhari_support@softwaretree.com](mailto:gilhari_support@softwaretree.com)

## License

This example code is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Important:** This license applies ONLY to the example code in this repository. The Gilhari software (including the softwaretree/gilhari Docker image and Gilhari SDK) and the embedded JDX ORM software are proprietary products owned by Software Tree.

The Gilhari Docker image includes an evaluation license for testing purposes. For production use or licensing beyond the evaluation period, please visit [https://www.softwaretree.com](https://www.softwaretree.com) or contact [gilhari_support@softwaretree.com](mailto:gilhari_support@softwaretree.com).

---

**Ready to try it?** Start with the [Quick Start](#quick-start) section above!