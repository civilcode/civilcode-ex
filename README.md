# CivilCodeEx: DDD and Types

The foundation library contains the building blocks for Domain-Driven Design applications
and some basic types such as `CivilCode.Maybe` and `CivilCode.Result`.

The generated documentation can be viewed at: http://civilcode-ex.s3-website-us-east-1.amazonaws.com/

## About CivilCode Inc

[CivilCode Inc.](https://www.civilcode.io) develops tailored business applications in
[Elixir](http://elixir-lang.org/) and [Phoenix](http://www.phoenixframework.org/) in Montreal, Canada.

# Domain-Driven Design Implementation Guide

## Background

This document assumes an understanding of the strategic and tactical concepts for
[Domain-Driven Design](https://en.wikipedia.org/wiki/Domain-driven_design) (DDD). The building
blocks of a domain model include some or all of the following:

* Entity (5)
* Value object (6)
* Service (7)
* Domain Event (8)
* Aggregate (10)
* Factory (11)
* Repository (12)

(see Influences for the reason why concepts have numbers)

The domain model is accessed and integrated with:

* Application Service (14)
* Adapters (for ports)

This document won't describe these concepts in detail so it's important to read the source
materials. Our [DDD education trail](https://civilcode.gitbook.io/playbook/education/trails/domain-driven-design)
is a good place to start.

## Purpose

The purpose of this guide is to communicate our approach to DDD. There are a number of benefits for
using DDD:

* ensures the domain model reflects our customers language
* provides a shared opinion on how applications are built at CivilCode
* provides a pattern language to discuss with other team members
* enables us to navigate an application without re-learning a new structure every time
* reduces the overhead of understanding the structure of the code, reading, maintainability
* reduces the number of decisions on how to structure an application
* allows us to focus on solving client problems, not architecture problems (at least 90% of those)
* results in shared-ownership of the codebase, we don't know who wrote it, eliminates personal
  styles

## Influences

Our approach to DDD is influenced by the following books:

* [Implementing Domain-Driven Design](https://books.google.ca/books?id=X7DpD5g3VP8C)(IDDD)
* [Domain Modeling Made Functional](https://books.google.ca/books?id=qA9QDwAAQBAJ)
* [Secure By Design](https://books.google.ca/books?isbn=1617294357)

As the IDDD book is our primary resource for understanding DDD, we reference the chapter
numbers each time we mention a core concept in case you need clarification on that concept.
This mimics how the book is written, e.g. Domain Events (8). The IDDD book provides an
[example application](https://github.com/VaughnVernon/IDDD_Samples) which has been a strong
influence for our architecture.

Beyond key concepts of DDD other related influences are:

* Hexagonal or Ports and Adapters [IDDD pg125]
* Algebraic Data Types (ADT); read [Design with Types](https://fsharpforfunandprofit.com/posts/designing-with-types-intro/#series-toc)
* Event Storming; watch [Event Storming for Fun and Profit](https://www.youtube.com/watch?v=OcIu-dvrXhY)

Other references include:

* [Enterprise Craftsmanship - Vladimir Khorikov](https://enterprisecraftsmanship.com)

## Key Design Principles

* Validate data at the boundaries; read [Life at the Boundaries: Conversion and Validation](https://blog.startifact.com/posts/conversion-and-validation.html)
* Reason about the application with events; watch [The Many Meanings of Event-Driven Architecture](https://www.youtube.com/watch?v=STKCRSUsyP0)
* Optimize for Deletability; watch [Optimize for Deletability](https://vimeo.com/108441214)
* Making illegal states unrepresentable; read [Designing with types: Making illegal states unrepresentable](https://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/)

## DDD Architecture Styles

DDD provides us with a set of tools to develop an application. We may apply some but not all
of these building blocks in an application. We provide "Just Enough DDD" as needed. For example,
it would not be appropriate to design an application with Domain Events when a
simple CRUD style application would suffice. We should always choose the simplest style of
application appropriate. Often we will start with a Simple Architecture and as we experience a
pain point, e.g. an update operation not does reflect the complexity of the use case, we refactor
into a more complex style, such as the Rich-Domain.

Our styles of application enables us to refactor from one style to another with the less amount
of friction. Our clients `platform` consists of a number of applications and each of those
applications may exhibit a different style of DDD.

We have two application styles:

1. **Simple-Domain Architecture**: suitable for CRUD style applications. We should always consider this
   style first.
2. **Rich-Domain Architecture**: implement concepts from our Event Storming such as commands,
  aggregates, and events with weak (implicit) or strong types (explicit). This is our sweet-spot
  for the type of business applications we develop.

These application styles handle commands only. Commands do not need to persist in the database,
but involve domain logic, e.g. calculate a "return on investment". Simple queries are
handled in the web application as these are often coupled to the user interface.

## Application Foundation

All application styles share the same foundation:

1. Directory Structure
2. Application Service (14)
3. Data Application

### Directory Structure

A full directory structure for an application is demonstrated by this example:

    acme_core/lib/acme_core/
                           /catalog
                           /inventory
                           /sales
                             config.ex
                             adapters/
                               order_repository.ex
                             application/
                               order/
                                 complete_order.ex
                                 cancel_order.ex
                                 order_application_service.ex
                                 order_process_manager.ex
                               payment/
                                 payment_application_service.x
                             domain/
                               order/order.ex
                                     order_item.ex
                                     order_completed.ex
                                     order_canceled.ex
                                     customer_discount_service.ex
                               payment/payment.ex
                                       payment_completed.ex

The key directories in this file structure are:

The application represents the "core" behaviour of the application.

* `adapters`: The adapters for ports in a Hexagonal [IDDD pg125] architecture. e.g. a repository
   adapter for a database.
* `application`: The application concerns separating the domain model from concerns such as
  transactions and other infrastructure.
* `domain`: The model representing the problem domain, using building blocks such as Entities
  forming Aggregates, Value Objects and Domain Events.
* `services`: Domain Services, not Application Services. Some may argue that Domain Services
  should be in the `domain` directory, however Domain Services may not be pure
  (i.e have side-effects), by separating out services, we keep the domain functionally pure.
* `config.ex`: This encapsulates configuration options that can be injected into functions.

### Application Service (14)

An Application Service is the entry point into your application that implements a business use case.
The Application Service can evolve from a simple CRUD operations to handling an explicit
command.

### Data Application

For each platform a "data" application provides the `CivilCode.Record` and `CivilCode.ValueObjects`
used across many applications. These types are defined using Ecto and typically persisted in a RDMBS.

    acme_data/lib/acme_data/
      catalog/
        product_record.ex
      sales/
        order_record.ex
        order_item_record.ex
        quantity.ex
    acme_core/lib/acme_core/

Structuring the application this way simplifies how the application interacts with the RDMBS,
especially when testing (e.g. factories).

### Basic Functional Concepts

Before moving into the architecture styles, here are a few notes on writing code in a
functional style:

* favour pure functions over impure
* impure functions are those who have side-effects read, write to DB, sending email -- anything to
do with the "outside" world
* do not call an impure function from a pure function. You've just made it impure :-(
* use a dedicated function to co-ordinate pure and impure functions
* impure functions are used at the boundaries

## 1. Simple Architecture

This application style is appropriate for CRUD. It uses an Application Service for a specific
data type (e.g. `ProductApplicationService`) to create and update records using `Ecto.Changeset`.
The `domain` has modules with domain actions, typically `create` and `update` that return
Ecto Changesets.

An example based on modules and typespecs:

```elixir
# apps/magasin_core/lib/magasin_core/sales/application/product_application_service.ex
defmodule ProductApplicationService do
  use CivilCode.ApplicationService

  @spec new_product() :: Changeset.t(Product.t)
  @spec create_product(Params.t) :: {:ok, Product.t} | {:error, Changeset.t(Product.t) }
  @spec edit_product(EntityId.t) :: Changeset.t(Product.t)
  @spec update_product(EntityId.t, Params.t) :: {:ok, Product.t} | {:error, Changeset.t(Product.t) }
end

# apps/magasin_core/lib/magasin_core/sales/domain/product.ex
defmodule MagasinCore.Catalog.Product do
  use CivilCode.Entity

  @type t :: MagasinData.Catalog.Product.t

  @spec create(Params.t) :: valid_or_invalid_changset :: Changeset.t(t)
  @spec update(t, Params.t) :: valid_or_invalid_changset :: Changeset.t(t)
end
```

## 2. Rich-Domain Architecture

This application style is the sweet spot for CivilCode for many of the domain problems we solve.
The migration from a simple CRUD application to a Rich-Domain is triggered when business rules are
introduced, going beyond simple validation rules.

The key characteristics of a Rich-Domain Architecture are:

* commands are used to validate params at the boundary (this is one of the key design principles in simplifying the domain)
* once inside the application service module value objects are used, i.e. validated types
* domain actions receive validated types only (i.e. not `CivilCode.Params.t`)
* a repository for the aggregate is required
* use a `CivilCode.DomainEvent` to communicate between bounded contexts if required

```elixir
# apps/magasin_core/lib/magasin_core/sales/application/order_application_service.ex
defmodule MagasinCore.Sales.OrderApplicationService do
  use CivilCode.ApplicationService

  @spec handle(PlaceOrder.t) ::
    {:ok, order_id :: EntityId.t} | {:error, BusinessException.t |  RepositoryError.t}
  @spec handle(CancelOrder.t) ::
    {:ok, order_id :: EntityId.t} | {:error, BusinessException.t | RepositoryError.t}
end

# apps/magasin_core/lib/magasin_core/sales/adapter/order_repository.ex
defmodule MagasinCore.Sales.OrderRepository do
  use CivilCode.Repository

  # See Behaviour for more details. Repositories return RepositoryError for a unique constraint violation.
end

# apps/magasin_core/lib/magasin_core/sales/domain/order.ex
defmodule MagasinCore.Sales.Order do
  use CivilCode.Entity

  @type t :: MagasinData.Sales.Order.t

  @spec place(t, Email.t, Product.t, Quantity.t) :: {:ok, Changeset.t(t)} | {:error, BusinessException.t}
  @spec cancel(t) :: {:ok, Changeset.t(t)} | {:error, BusinessException.t}
end
```

Alternatively, if a custom schema is required:

```elixir
# apps/magasin_core/lib/magasin_core/sales/domain/order.ex
defmodule MagasinCore.Sales.Order do
  use CivilCode.Entity

  embedded_schema do
    field :email, Email
    field :product_id, CivilCode.EntityId
    field :quantity, Quantity
  end

  @spec place(t, Email.t, Product.t, Quantity.t) :: {:ok, Changeset.t(t)} | {:error, BusinessException.t}
  @spec cancel(t) :: {:ok, Changeset.t(t)} | {:error, BusinessException.t}
end
```

## Building Blocks

The CivilCodeEx repository provides the following building blocks for your application. Each
building block provide macros to make it easier to get started. You can use these macros directly,
or alternatively include them in your application specific macros. The building blocks also provide
documentation in how to use them in more details that exceeds the scope of this document.

* `CivilCode.ApplicationService` (14)
* `CivilCode.QueryService`
* `CivilCode.Entity` (5)
* `CivilCode.ValueObject` (6)
* `CivilCode.DomainService` (7)
* `CivilCode.DomainEvent` (8)
* `CivilCode.AggregateRoot` (10)
*  Factory (11)
* `CivilCode.Repository` (12)
