Dynamics® Busness Central

GNC-FRD – Functionnal Requirement Document

SELL

VERSION 0.1

**Project**

GNC

**Document prepared by**

- Mr Hosni Jaouahdou

# TABLE OF CONTENTS

[2 Document control [4](#document-control)](#document-control)

[2.1 Version History [4](#version-history)](#version-history)

[2.1 Attached documents [4](#attached-documents)](#attached-documents)

[2.1 Email List [4](#email-list)](#email-list)

[2.2 Approvals [5](#approvals)](#approvals)

[3 Introduction [6](#introduction)](#introduction)

[3.1 Objectives [6](#objectives)](#objectives)

[3.2 Validation [6](#validation)](#validation)

[3.3 Conventions and Terminology [6](#conventions-and-terminology)](#conventions-and-terminology)

[4 Methodology [8](#methodology)](#methodology)

[5 Sales Process [9](#sales-process)](#sales-process)

[9.1 Customer Management [9](#customer-management)](#customer-management)

[6 POS [10](#_Toc234218517)](#_Toc234218517)

[6.1 Description of the requirement (Client) [10](#_Toc234218518)](#_Toc234218518)

[6.2 Refund [10](#_Toc234218519)](#_Toc234218519)

[6.3 Description of the requirement (Client) [10](#description-of-the-requirement-client)](#description-of-the-requirement-client)

[6.4 Change [11](#_Toc234218521)](#_Toc234218521)

[6.4.1 Description of the requirement (Client) [11](#_Toc234218522)](#_Toc234218522)

[6.5 Deposit [11](#_Toc234218523)](#_Toc234218523)

[6.5.1 Description of the requirement (Client) [11](#_Toc234218524)](#_Toc234218524)

[10.6 Complaints Management [11](#sales-order-shipment-invoice)](#sales-order-shipment-invoice)

[6.5.2 Description of the standard response via the BUSINESS CENTRAL 365 solution: [12](#_Toc234218526)](#_Toc234218526)

[6.5.3 Description of the project solution : [12](#description-of-the-project-solution-1)](#description-of-the-project-solution-1)

[7 Maintenance [13](#_Toc234218528)](#_Toc234218528)

[8 Collection of management and monitoring reports [14](#collection-of-management-and-monitoring-reports)](#collection-of-management-and-monitoring-reports)

# Document control

## 2.1 Version History

| Date       | Author          | Version | Reference of modifications |
|------------|-----------------|---------|----------------------------|
| 06/07/2026 | Hosni Jaouahdou | 0.1     |                            |
|            |                 |         |                            |
|            |                 |         |                            |

## 2.1 Attached documents

| Document Name / Reference | Version | Date |
|---------------------------|---------|------|
|                           |         |      |
|                           |         |      |
|                           |         |      |

## Email List

| Organization | Name                         |
|--------------|------------------------------|
| GNC          | Mr. Abdessalem Atman Abdelli |
| GNC          | Mr. Mohammed HAMAD           |
| GNC          | Mr. Hossam Amro              |
| GNC          | Mr. Mazen Nasr               |
| GNC          | Mr. Ahmed Rashad             |
| GNC          | Mr. Ahmed Raouf              |
| GNC          | Mr. Islam Rashad             |
| NAVIONE      | Mr Hosni Jaouahdou           |
|              |                              |
|              |                              |

## Approvals

| Key User                    | Fonction | Date |     | Read & approved |     |     | Signature |     |
|-----------------------------|----------|------|-----|-----------------|-----|-----|-----------|-----|
| Mr Abdelmoneem Hajii        |          |      |     | Read & approved |     |     |           |     |
| Mr Abdessalem Atman Abdelli |          |      |     | Read & approved |     |     |           |     |
| Mr. Mohammed HAMAD          |          |      |     | Read & approved |     |     |           |     |
| Mr Hossam Amro              |          |      |     | Read & approved |     |     |           |     |
| Mr. Mazen Nasr              |          |      |     | Read & approved |     |     |           |     |
| Mr. Ahmed Rashad            |          |      |     | Read & approved |     |     |           |     |
| Mr. Ahmed Raouf             |          |      |     | Read & approved |     |     |           |     |
| Mr. Islam Rashad            |          |      |     | Read & approved |     |     |           |     |
| Mr Hosni JAWAHDOU           |          |      |     | Read & approved |     |     |           |     |

# Introduction

## Objectives

The objective of this document is to transcribe the business and process needs identified during the analysis workshops of the GNC project, in common terms and to describe how these needs will be covered and addressed in the Microsoft Dynamics® 365 Business Central solution, within the defined project scope.

The objectives of the analysis are:

- Analyze the fits and gaps between the needs and the Microsoft Dynamics® BUSINESS CENTRAL 365 solution

- Identify changes in the scope of the project since the diagnostic phase

- Prepare the settings

- Prepare for data recovery

- Prepare for the implementation of adaptations

- Prepare the interfaces

- Provide the elements enabling confirmation or revision of the costing of the system integration.

Any gaps between functional needs and standard processes of the solution or scope gaps will be highlighted and collected in the “Gap Matrix” document.

The resolution proposals in this document will serve as the basis for the next design phase.

## Validation

The Functional Requirement Document (FRD) for a functional area is the main deliverable of the analysis phase. Each FRD therefore requires formal approval from the relevant area manager and the GNC project manager to be considered validated. Validation by representatives of the GNC Project Management and BUSINESS CENTRAL 365IONE may be required.

## Conventions and Terminology

Importance:

\- H: high (essential)

\- M: medium (necessary)

\- L: low (optional)

Résolution

- \- S: Standard (configuration without development)

- \- O: Organizational rule

- \- C: Custom (application customization required)

- \- I: Interfaces to be planned

#  Methodology

The methodology adopted in drafting this document consists of transcribing the specific user needs collected during the analysis and, on the other hand, briefly indicating the other standard features applied to the relevant modules.

Custom developments will be identified and compared with the new features of **MICROSOFT DYNAMICS 365 BUSINESS CENTRAL** to determine the appropriateness technical and functional feasibility of their integration into the new project.

# Sales Process

## 9.1 Customer Management

The information related to the customer file is as follows:

- Code.

- Name (Manadatoty).

- Balance.

- Adress.

- Type.

- City.

- Area.

- Line.

- Sector.

- Business Unit.

- Division.

- Country.

- Region.

- Location.

- Number phone (Mandatory).

- GLN (Mandatory).

- CR number (Mandatory).

- E-mail.

- Observation

- Contact Name.

- Contact Phone Number.

- Contact E-mail.

- Historical :

  - Sales.

> o Failed sales.
>
> o Credit memo.
>
> o Bonus.

- Target (By Year)

## Sales Representatives

Sales representatives are responsible for collecting customer needs and creating customer requests in the system. They act as the main commercial contact between the company and the customer during the request collection phase.

The sales representative captures the customer’s demand, including the requested products, quantities, prices, discounts if applicable, and total amount. These requests are then reviewed and transformed into confirmed sales orders according to the defined business rules.

Two types of sales representatives are managed in the system :

<table>
<colgroup>
<col style="width: 34%" />
<col style="width: 65%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Sales Representative Type</strong></th>
<th><strong>Description</strong></th>
</tr>
<tr class="odd">
<th><p><strong>PRIVATE Sector :</strong></p>
<ul>
<li><p>Pharma</p></li>
<li><p>OTC</p></li>
<li><p>Medical Device</p></li>
</ul></th>
<th></th>
</tr>
<tr class="header">
<th><p><strong>Goverment :</strong></p>
<ul>
<li><p>Institution</p></li>
<li><p>Tender</p></li>
<li><p>Medical Device</p></li>
</ul></th>
<th></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><del>Pharma Sales Representative</del></td>
<td><del>Responsible for pharmaceutical products and related customer requests.</del></td>
</tr>
<tr class="even">
<td><del>Medical Device Sales Representative</del></td>
<td><del>Responsible for medical devices and related customer requests.</del></td>
</tr>
</tbody>
</table>

Each sales representative is assigned to a defined customer portfolio. This means that customers are linked to their responsible sales representative in order to ensure clear ownership, follow-up, and accountability.

In addition, each sales representative has an annual sales target to achieve. The annual target is used to monitor commercial performance, compare actual sales against planned objectives, and support management reporting.

### Business Rules

1.  Each sales representative must have a defined type: Pharma or Medical Device.

2.  Each sales representative may be assigned to one or multiple customers.

3.  Each customer may have a responsible sales representative based on the product category or business assignment.

4.  Each sales representative must have an annual sales target.

5.  Customer requests created by a sales representative must remain linked to that sales representative.

6.  Sales orders generated from customer requests must keep traceability of the sales representative at line level when needed.

7.  The system should allow management to monitor the achievement rate of each sales representative against the annual target.

### Functional Requirements

| **Requirement ID** | **Requirement Description**                                                                                     |
|--------------------|-----------------------------------------------------------------------------------------------------------------|
| REQ-SR-001         | The system shall allow the creation and management of sales representatives.                                    |
| REQ-SR-002         | The system shall classify sales representatives by type: Pharma or Medical Device.                              |
| REQ-SR-003         | The system shall allow assigning customers to sales representatives.                                            |
| REQ-SR-004         | The system shall allow assigning an annual sales target to each sales representative.                           |
| REQ-SR-005         | The system shall link each customer request to the sales representative who collected the need.                 |
| REQ-SR-006         | The system shall keep sales representative traceability when customer requests are converted into sales orders. |
| REQ-SR-007         | The system shall provide reporting to compare actual sales versus annual target by sales representative.        |

## Requests (PO)

A Customer Request represents a commercial demand received from a customer and collected by the sales team before being converted into a confirmed sales order.

The customer request is used to capture the initial needs expressed by the customer, including the requested products, quantities, prices, discounts, and total amounts. It allows the sales team to centralize customer demands, review them, and transform validated requests into confirmed sales orders.

Customer requests may be created by different sales representatives. Each request remains linked to the sales representative who collected it in order to ensure proper follow-up, traceability, and commission or performance tracking when required.

## Description of the requirement (Client)

Customer requests are collected by the sales team based on information provided by customers.

Once the request is reviewed and validated, it is transformed into a Confirmed Sales Order.

The main information provided by the customer includes:

| **Information** | **Description**                                  |
|-----------------|--------------------------------------------------|
| Product         | The item or service requested by the customer    |
| Quantity        | The requested quantity for each product.         |
| Price           | The agreed unit price for the requested product. |
| Discount        | The agreed unit price for the requested product. |
| Total Amount    | The total amount for each line                   |

Business Rules

- Each customer request must be linked to a customer origin/source.

- A customer request must include at least one product line.

- Each product line must contain the product, quantity, unit price, and total amount.

- Discount is optional and should be applied only when granted to the customer.

- When two or more customer requests created by different sales representatives have the same customer origin, only \*\*one confirmed sales order\*\* must be generated.

- In case of grouped requests, the confirmed sales order must consolidate all products requested by the same customer origin.

- Each sales representative must remain linked to the products originating from his/her own customer request.

- The system must keep traceability between:

  - The original customer request.

  - The sales representative.

  - The product lines.

  - The generated confirmed sales order.

Expected System Behavior

When customer requests are validated, the system shall check whether multiple requests have the same customer origin issue from different sales representative.

If several requests share the same customer origin, the system shall generate a single confirmed sales order containing all related product lines.

Each product line in the confirmed sales order shall keep the reference of the sales representative who submitted the original request.

This ensures that the customer receives one consolidated sales order while maintaining internal traceability of the commercial contribution of each sales representative.

### Remark

For some specific customers, the system shall allow the assignment of predefined sales representatives and their associated products.

This means that when a customer request is created for these customers, the system may automatically identify or suggest the sales representative responsible for specific products linked to that customer.

This rule helps ensure proper commercial ownership, accurate follow-up, and clear traceability of sales responsibilities by product and by customer.

### Description of the standard response via the BUSINESS CENTRAL 365 solution: 

### Description of the project solution :

<table style="width:100%;">
<colgroup>
<col style="width: 5%" />
<col style="width: 7%" />
<col style="width: 20%" />
<col style="width: 28%" />
<col style="width: 3%" />
<col style="width: 29%" />
<col style="width: 5%" />
</colgroup>
<thead>
<tr class="header">
<th><blockquote>
<p><mark>Process ID</mark></p>
</blockquote></th>
<th><blockquote>
<p><mark>Sub-process</mark></p>
</blockquote></th>
<th><mark>Description of the requirement</mark></th>
<th><mark>Business Rules</mark></th>
<th>Importance</th>
<th><mark>Responding to the need</mark></th>
<th>Résolution</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>1.1</td>
<td></td>
<td>Client Request Managment</td>
<td>The system shall allow the creation of customer requests by sales representatives.</td>
<td>H</td>
<td>Client Request</td>
<td>S</td>
</tr>
<tr class="even">
<td>1.2</td>
<td></td>
<td>Client Request Managment</td>
<td>The system shall allow the user to enter customer origin, product, quantity, price, discount, and total amount.</td>
<td>H</td>
<td>Client Request Detail</td>
<td>S/C</td>
</tr>
<tr class="odd">
<td>1.3</td>
<td></td>
<td>Client Request Managment</td>
<td>The system shall allow the validation of customer requests before conversion into sales orders.</td>
<td>H</td>
<td>Client Request</td>
<td>S</td>
</tr>
<tr class="even">
<td>1.4</td>
<td></td>
<td>Request Grouped</td>
<td>The system shall group requests having the same customer origin into one confirmed sales order.</td>
<td>H</td>
<td>New Function</td>
<td>C</td>
</tr>
<tr class="odd">
<td>1.5</td>
<td></td>
<td>Request Grouped</td>
<td>The system shall keep the sales representative reference on each Request line.</td>
<td>H</td>
<td></td>
<td>C</td>
</tr>
<tr class="even">
<td>1.6</td>
<td></td>
<td>Sales Order</td>
<td>The system shall generate a confirmed sales order from validated customer requests.</td>
<td>H</td>
<td>Sales Order attached to the request</td>
<td>S/C</td>
</tr>
<tr class="odd">
<td>1.7</td>
<td></td>
<td>Customer-Sales Representatives</td>
<td>the system shall allow the assignment of predefined sales representatives and their associated products.</td>
<td>H</td>
<td>New menu</td>
<td>C</td>
</tr>
</tbody>
</table>

# 10.6 Sales Order – Shipment & Invoice

<span id="_Toc234218526" class="anchor"></span>Sales orders are generated based on validated customer requests. Once the customer request is reviewed and confirmed, the system creates a sales order containing the approved customer, products, quantities, prices, discounts if applicable, and total amounts.

The sales order represents the official commercial document used to process the customer demand. It keeps the link with the original customer request in order to ensure full traceability between the collected need, the responsible sales representative, and the generated order.

After the sales order is confirmed, the shipment process is handled by the warehouse team. The warehouse team is responsible for preparing the requested products, checking available stock, validating quantities to be shipped, and posting the shipment in the system.

Once the shipment is completed, the invoice can be generated based on the shipped quantities. The invoice reflects the products delivered to the customer and becomes the official financial document used for customer billing.

**Remark :**

Stock will be decreased after Posting the invoice

### Business Process

| **Step**                        | **Description**                                                 | **Responsible Team** |
|---------------------------------|-----------------------------------------------------------------|----------------------|
| 1\. Customer Request Validation | Customer requests are reviewed and validated before conversion. | Sales Team           |
| 2\. Sales Order Creation        | A sales order is generated based on the validated request.      | Sales Team / System  |
| 3\. Stock Preparation           | Products are prepared according to the sales order lines.       | Warehouse Team       |
| 4\. Shipment Posting            | The warehouse team validates and posts the shipment.            | Warehouse Team       |
| 5\. Invoice Generation          | The invoice is generated based on shipped quantities.           | Sales / Finance Team |
| 6\. Customer Billing            | The customer invoice is posted and used for payment follow-up.  | Finance Team         |

### Business Rules

1.  A sales order must be generated only from validated customer requests.

2.  The sales order must keep reference to the original customer request.

3.  The sales order must include the customer, products, quantities, prices, discounts, and total amount.

4.  Shipment must be handled by the warehouse team.

5.  The warehouse team must check stock availability before shipment.

6.  The shipped quantity may be equal to or lower than the ordered quantity depending on available stock.

7.  The invoice must be generated based on the shipped quantity.

8.  The system must keep traceability between:

    - Customer Request

    - Sales Order

    - Shipment

    - Invoice

### Functional Requirements

| **Requirement ID** | **Requirement Description**                                                                       |
|--------------------|---------------------------------------------------------------------------------------------------|
| REQ-SO-001         | The system shall generate sales orders from validated customer requests.                          |
| REQ-SO-002         | The system shall keep a reference between the sales order and the original customer request.      |
| REQ-SO-003         | The system shall allow the warehouse team to prepare and process shipments.                       |
| REQ-SO-004         | The system shall allow stock availability checking before shipment.                               |
| REQ-SO-005         | The system shall allow partial shipment when available stock is lower than ordered quantity.      |
| REQ-SO-006         | The system shall generate invoices based on shipped quantities.                                   |
| REQ-SO-007         | The system shall ensure traceability from customer request to sales order, shipment, and invoice. |

### Description of the standard response via the BUSINESS CENTRAL 365 solution: 

### Description of the project solution :

<table style="width:100%;">
<colgroup>
<col style="width: 5%" />
<col style="width: 7%" />
<col style="width: 20%" />
<col style="width: 28%" />
<col style="width: 3%" />
<col style="width: 29%" />
<col style="width: 5%" />
</colgroup>
<thead>
<tr class="header">
<th><blockquote>
<p><mark>Process ID</mark></p>
</blockquote></th>
<th><blockquote>
<p><mark>Sub-process</mark></p>
</blockquote></th>
<th><mark>Description of the requirement</mark></th>
<th><mark>Business Rules</mark></th>
<th>Importance</th>
<th><mark>Responding to the need</mark></th>
<th>Résolution</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>S</td>
</tr>
<tr class="even">
<td></td>
<td></td>
<td></td>
<td><ul>
<li></li>
</ul></td>
<td></td>
<td></td>
<td>S/C</td>
</tr>
<tr class="odd">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>S</td>
</tr>
<tr class="even">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>C</td>
</tr>
<tr class="odd">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>C</td>
</tr>
<tr class="even">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>C</td>
</tr>
</tbody>
</table>

# Discount & Bonus

The system shall manage discounts and bonuses based on customer, product, and predefined commercial rates. This functionality allows the company to apply specific commercial conditions depending on the customer profile, product, sales agreement, or promotional policy.

Discounts and bonuses may be defined at customer level, product level, or customer-product combination level. These rules are used during customer request creation and sales order processing to ensure that the correct commercial conditions are applied automatically or proposed to the sales representative for validation.

### Discount Management

A discount represents a reduction applied to the product price. The discount may be granted based on customer agreement, product promotion, quantity ordered, or management approval.

The system shall allow defining discount rates by :

| **Discount Level** | **Description**                                                                         |
|--------------------|-----------------------------------------------------------------------------------------|
| Customer           | A specific discount rate assigned to a customer.                                        |
| Product            | A discount rate assigned to a specific product.                                         |
| Customer + Product | A specific discount rate applied only when a defined customer orders a defined product. |
| Product Category   | A discount rate applied to a group or category of products.                             |

When a customer request or sales order is created, the system should retrieve the applicable discount rate based on the customer and product combination.

The discount may be applied automatically or suggested to the sales representative depending on the system setup and authorization rules.

### Bonus Management

A bonus represents a free quantity granted to a customer for a specific product according to the company’s commercial policy.

The bonus shall be configured by customer and product. For each eligible customer-product combination, the system shall define the bonus quantity to be granted.

The bonus shall not be applied as a discount on the original sales order line. Instead, when a sales order is generated or confirmed, the system shall automatically insert a new sales order line for the bonus quantity.

The generated bonus line shall use the same product, the configured bonus quantity, and a 100% discount. As a result, the bonus line amount shall be equal to zero while keeping the free quantity visible and traceable in the sales order, shipment, and invoice.

### Bonus Setup

The bonus setup shall include the following information :

| **Setup Field** | **Description**                                                      |
|-----------------|----------------------------------------------------------------------|
| Customer        | The customer eligible for the bonus.                                 |
| Product         | The product concerned by the bonus rule.                             |
| Bonus Quantity  | The free quantity to be granted to the customer.                     |
| % Discount      | Additionnal Discount must by added to the pricipal discount if exist |

### Expected System Behavior

When a sales order is generated from a validated customer request, the system shall check whether a bonus rule exists for the selected customer and product.

If a bonus rule exists, the system shall automatically insert an additional sales order line for the same product with the configured bonus quantity.

The inserted bonus line shall have a 100% discount, making the line amount equal to zero.

The bonus line shall remain visible in the sales order, shipment, and invoice to ensure full traceability and stock movement.

### Example

A customer places a request for a specific product:

| **Customer** | **Product** | **Ordered Quantity** | **Unit Price** | **Discount Rate** |
|--------------|-------------|----------------------|----------------|-------------------|
| Customer A   | Product X   | 100                  | 50             | 10%               |

The bonus setup contains the following rule:

| **Customer** | **Product** | **Bonus Quantity** |
|--------------|-------------|--------------------|
| Customer A   | Product X   | 5                  |

The generated sales order shall contain two lines:

The system should mange the MOH discount (Linked to The Bonus) and the add the additional discount (If Exist), and the bonus (If Exist)

| **Line Type**        | **Product** | **Quantity** | **Unit Price** | **Discount** | **Line Amount** |
|----------------------|-------------|--------------|----------------|--------------|-----------------|
| Ordered Product Line | Product X   | 100          | 50             | 10%          | 4,500           |
| Bonus Product Line   | Product X   | 5            | 50             | 100%         | 0               |

The ordered line is billed to the customer after applying the discount.  
The bonus line is delivered to the customer for free and does not impact the invoice amount.

### Business Rules

1.  The system shall allow defining discount rates by customer.

2.  The system shall allow defining discount rates by product.

3.  The system shall allow defining discount rates by customer-product combination.

4.  The system shall allow defining bonus rules by customer and product.

5.  Bonus shall be managed as a quantity.

6.  The bonus quantity shall be inserted as a new sales order line.

7.  The bonus line shall use the same product as the original ordered product.

8.  The bonus line shall have a 100% discount.

9.  The bonus line amount shall be equal to zero.

10. Bonus lines shall not impact the customer billing amount.

11. Bonus lines shall impact stock movement during shipment.

12. The bonus line shall remain visible in the sales order, shipment, and invoice for traceability.

13. During customer request creation, the system should suggest the applicable discount based on the selected customer and product.

14. During sales order creation, the system shall apply the validated discount and generate the applicable bonus line.

15. Manual discount modification should be controlled based on user authorization.

16. Manual modification or deletion of bonus lines should be controlled based on user authorization.

17. If multiple discount rules are applicable, the system shall apply the priority rule defined in setup.

18. The system shall allow management to review and validate exceptional discounts when required.

19. The system shall keep traceability between:

- Customer Request

- Sales Order

- Original Sales Line

- Bonus Sales Line

- Shipment

- Invoice

### Functional Requirements

| **Requirement ID** | **Requirement Description**                                                                                |
|--------------------|------------------------------------------------------------------------------------------------------------|
| REQ-DB-001         | The system shall allow defining discount rates by customer.                                                |
| REQ-DB-002         | The system shall allow defining discount rates by product.                                                 |
| REQ-DB-003         | The system shall allow defining discount rates by customer-product combination.                            |
| REQ-DB-004         | The system shall allow defining bonus rules by customer and product.                                       |
| REQ-DB-005         | The system shall allow defining the bonus as a quantity.                                                   |
| REQ-DB-006         | The system shall automatically suggest applicable discounts during customer request creation.              |
| REQ-DB-007         | The system shall automatically check the applicable bonus rule during sales order generation.              |
| REQ-DB-008         | The system shall automatically insert a separate sales order line for the bonus quantity.                  |
| REQ-DB-009         | The system shall apply 100% discount on the generated bonus line.                                          |
| REQ-DB-010         | The system shall make the bonus line amount equal to zero.                                                 |
| REQ-DB-011         | The system shall apply validated discounts and bonuses when generating the sales order.                    |
| REQ-DB-012         | The system shall keep bonus lines visible in the sales order, shipment, and invoice.                       |
| REQ-DB-013         | The system shall ensure that bonus quantities generate stock movement during shipment.                     |
| REQ-DB-014         | The system shall keep traceability between the original ordered product line and the generated bonus line. |
| REQ-DB-015         | The system shall control manual discount modification based on user authorization.                         |
| REQ-DB-016         | The system shall control manual modification or deletion of bonus lines based on user authorization.       |
| REQ-DB-017         | The system shall allow approval workflow for exceptional discounts when required.                          |

# Collection of management and monitoring reports

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><ul>
<li><p>Sales</p></li>
</ul>
<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th><ul>
<li><p>Quoted Sales.</p></li>
</ul></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><ul>
<li><p>Proforma Sales.</p></li>
</ul></td>
</tr>
<tr class="even">
<td><ul>
<li><p>Invoiced Sales</p></li>
</ul></td>
</tr>
<tr class="odd">
<td><ul>
<li><p>Sales by Product</p></li>
</ul></td>
</tr>
<tr class="even">
<td><ul>
<li><p>Sales by Customer</p></li>
</ul></td>
</tr>
<tr class="odd">
<td><ul>
<li><p>Sales by Region</p></li>
<li><p>Sales By Period.</p></li>
</ul></td>
</tr>
</tbody>
</table></td>
</tr>
</tbody>
</table>
