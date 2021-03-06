---
title: Concepts
description: Concepts
permalink: /docs/
layout: page
sidenav: concepts
sticky_sidenav: true
---

Three key concepts underlie the [OSCAL architecture](/OSCAL/docs/architecture/):

1. A 
[control](/OSCAL/docs/architecture/control/) is a safeguard or countermeasure designed to satisfy a set of defined security requirements. 

2. A [catalog](/OSCAL/docs/architecture/catalog/) is a set of security control definitions. Examples include the controls in NIST SP 800-53, ISO 27001, HIPAA, and PCI. The *catalog layer* in OSCAL refers to any data made available for processing in this format.

3. A [profile](/OSCAL/docs/architecture/profile/) is a specific set of security requirements; also called a *baseline* or *overlay*. A profile represents a selection of controls from one or more catalogs, with configuration or qualification appropriate to its use case. Profiles may be published with the catalogs from which they are derived, or they may be developed and maintained separately. Examples include the control baselines in NIST SP 800-53, the FedRAMP baselines, NIST SP800-171 (a controls baseline for CUI/NFO), and the PCI DSS requirements.  Profiles can be tailored based on the Confidentiality, Integrity, and Availability (CIA) requirements of the underlying system.

## Purpose

OSCAL is attempting to address a number of challenges around security controls and security control assessment. The core challenge, and one of the primary reasons for creating OSCAL, is that concepts like security controls and profiles are represented today largely in proprietary ways. In many cases they are written in prose documents that are imprecise, lead to differences in interpretation, and are not machine-readable; meaning that the prose instructions require someone to do manually implement the control in information systems in order for the tool to use the information.

Organizations are also struggling with information systems that have many different components. Some components require the use of different profiles per component; this is commonly the case with cloud environments. Also, systems can be multi-tenant or have mixed ownership of components (often referred to as shared responsibility). Information system owners need to be able to assess the security of these systems against their specific requirements and to simultaneously provide these views to their stakeholders.

In addition, there are situations where a single system needs to support multiple regulatory frameworks. For example, the U.S. Department of Veterans Affairs is a federal agency operating with multiple sets of regulatory frameworks together: the Federal Information Security Modernization Act (FISMA); the NIST Cybersecurity Risk Management Framework; requirements relating to the Health Insurance Portability and Accountability Act (HIPAA); and others relating to secure credit card transactions (Payment Card Industry Data Security Standard (PCI DSS)). This situation can be complicated.

Because the definition and assessment of all these security controls is so complex, it is largely a manual process today. The OSCAL project seeks to change this situation by offering standardized representations for controls and their implementation in a system, which can be used by both humans and machines for development, analysis, and reporting. We need formats that can be generated by machines for communicating with other machines, but can also be easily reformatted so humans can read the information. By standardizing the representation of this information with a well-defined specification, OSCAL information can be interoperable. The goal is to keep OSCAL as simple as possible while enabling extensive automation in future vendor tools.

## Users

The initial OSCAL work encompasses the catalog and profile concepts. There are several types of users who will benefit from OSCAL catalogs and profiles. They include the following producers of OSCAL catalogs, profiles, and/or tools:

- **Catalog maintainers:** publishing catalogs into OSCAL format (e.g., NIST, ISO, ISACA)
- **Standard profile maintainers:** profiles in OSCAL format used by many organizations consuming OSCAL catalogs (e.g., NIST, FedRAMP)
- **Custom profile maintainers:** developing new profiles or customizing existing profiles for organization-specific use (e.g., cloud service providers, integrators)
- **Tool vendors:** creating tools that use OSCAL to support risk assessment, continuous monitoring, compliance reporting, and other purposes

There are also several types of expected consumers of OSCAL catalogs, profiles, and/or tools, including the following:

- **Operations personnel:** rapidly verifying that systems comply with organizational security requirements
- **Security and privacy personnel:** automatically identifying problems and addressing them quickly before loss or damage occur
- **Auditors/assessors:** performing audits/assessments on demand with minimal effort
- **Policy personnel:** identifying systemic problems that necessitate changes to organizational security policies
