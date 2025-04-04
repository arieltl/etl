# ETL Project

This project implements a simple ETL (Extract, Transform, Load) pipeline in OCaml. It downloads CSV files over HTTP, parses and processes the data, and outputs the computed order totals and taxes.

## Project Structure
The project is managed using [Dune](https://dune.build/) and follows a standard OCaml project structure. The main components are:

- **bin/**: Contains the executable source files.
  - `main.ml`: Main entry point for the application.
  - `io.ml`: Handles impure I/O functions, including downloading CSV files.
  - `fileParsing.ml` & `parsing.ml`: Provide functions to parse CSV rows into OCaml types.
  - `types.ml`: Defines the data types (e.g., `order`, `fullOrder`, `orderTotal`, `processedOrderedItem`).



## Dependencies

The project relies on the following OCaml libraries:
- **csv**: For reading and writing CSV files.
- **Lwt**: For asynchronous operations.
- **cohttp-lwt-unix**: For HTTP requests.

These dependencies are declared in the [dune](bin/dune) files and in the `etl.opam` file.
These dependencies need to be installed trough OPAM before building the project.

Depending on the url of the csv file, the project may also require the tls support for the http requests. You can install tls-lwt package to add this support.

## Building the Project

Ensure you have [Dune](https://dune.build/) installed. From the root of the project, run:

````sh
dune build
````

## Executing the Project
To run the project, use the following command:

```sh
dune exec etl
```

### Parameters

The project accepts the following command-line parameters to filter and customize the ETL process:

- `-status <order_status>`  
  Specify the order status to filter by (e.g., `Cancelled`, `Pending`, `Complete`).

- `-origin <order_origin>`  
  Specify the order origin to filter by (e.g., `P` for Physical or `O` for Online).

You can combine these parameters to refine your filtering. For example, the following command processes only cancelled orders from Physical origin:

```sh
dune exec  etl -- -status Cancelled -origin P
```

If no parameters are provided, the project processes all orders.


## Report 
The project report is available in the [report.md](report.md) file. There is also a [report.pdf](report.pdf) version of the report.
