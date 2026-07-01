<div align="center">

#  Retail Analytics - Crisis Diagnostic & Recovery Strategy in 2020

### *An End-To-End Retail Analytics Pipeline From Retail Data To SQL Server And Power BI*

<p>
  <img src="https://img.shields.io/badge/SQL%20Server-Data%20Warehouse-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white" alt="SQL Server" />
  <img src="https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat-square&logo=powerbi&logoColor=black" alt="Power BI" /> 
</p>

</div>

---

## Introduction

An end-to-end data analytics and forecasting pipeline. The project turns raw transactional records into a cleaned analytical dataset, explores purchasing behavior, builds a dimensional data model, diagnoses a historical 49% drop in retail sales, compares machine learning approaches for demand forecasting, and publishes the BI-ready outputs into SQL Server for Power BI reporting.

## Table of Contents

- [Context](#context)
- [Dataset overview](#Dataset-overview)
- [Dataset Note](#dataset-note)
- [Data Pipeline](#data-pipeline)
- [Dimensional Model](#dimensional-model)
- [Power BI Dashboard](#power-bi-dashboard)
- [Project Overview](#project-overview)
- [Recommandation](#recommandation)
- [Conclusion](#conclusion)

## Context
- Global Retail Holdings is a multinational retail chain distributing consumer products—such as electronics, home appliances, accessories, and toys across 8 main categories (Computers, Cell Phones, Home Appliances, Audio, TV and Video, Games and Toys, Cameras and Camcorders, and Music)—in North America, Europe, Asia, and Australia. It operates a network of hundreds of physical stores across more than 20 countries, complemented by online sales channels.
- Operational structure: Organized according to a model of centralized merchandising and decentralized operations.
## Dataset Overview

### Main data files

| File | Description |
| --- | --- |
| `data/bronze/Tima_CRM - Data.csv` | Raw CRM export with customer, loan, product, location, income, credit, and repayment fields. |
| `data/silver/tima_cleaned_data_v1.csv` | Cleaned and enriched analytical dataset used for EDA and modeling. |
| `data/silver/tima_cleaned_with_clusters.csv` | Analytical dataset with K-Means customer cluster labels. |
| `data/gold/dim_fact_table/fact/Fact_Loans.csv` | Loan-level fact table for the Data Warehouse and Semantic Model. |

