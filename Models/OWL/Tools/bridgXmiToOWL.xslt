<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:bridg="http://www.bridgmodel.org/xslt/functions" exclude-result-prefixes="xs uml xmi bridg">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:param name="includeAnnotations" as="xs:boolean" select="true()"/>
  <xsl:variable name="owlNs" as="xs:string" select="'http://www.w3.org/2002/07/owl#'"/>
  <xsl:variable name="version" as="xs:string" select="/xmi:XMI/xmi:Extension/diagrams/diagram[properties/@name='BRIDG Sub-Domain Packages Diagram']/project/@version"/>
  <xsl:variable name="rootPackage" as="xs:string" select="'BRIDG Domain Information Model'"/>
  <xsl:variable name="modelPackages" as="xs:string+" select="xmi:XMI/uml:Model//packagedElement[@name=$rootPackage]/descendant-or-self::*[@xmi:type='uml:Package']/@xmi:id"/>
  <xsl:key name="elementById" match="/xmi:XMI/xmi:Extension/elements/element" use="@xmi:idref"/>
  <xsl:key name="classById" match="xmi:XMI/uml:Model//packagedElement[@name=$rootPackage]/packagedElement/*[@xmi:type='uml:Class']" use="@xmi:id"/>
  <xsl:template match="/" as="node()+">
    <xsl:if test="not(/xmi:XMI/@xmi:version=2.1)">
      <xsl:message terminate="yes">This transform only runs on XMI 2.1 exports</xsl:message>
    </xsl:if>
    <xsl:comment select="'&#x0a;
  - This content is wholely generated from the BRIDG UML model.  It should not be edited directly.&#x0a;
  -&#x0a;
  - For background on BRIDG and a deeper understanding of the domain model, refer to www.bridgmodel.org&#x0a;
  -&#x0a;
  - This ontology provides a representation of the classes, attributes and associations of the BRIDG data model.&#x0a;
  - It also identifies the package groupings for each class.  Classes, attributes and associations include&#x0a;
  - rich definitions and may also include mappings to one or more specifications maintained externally to&#x0a;
  - the BRIDG model.  The set of mappings provided represent those of specifications that have been submitted&#x0a;
  - for harmonization to BRIDG.  Many other mappings may well be possible.&#x0a;
  -&#x0a;
  - This ontology makes reference to HL7''s Abstract Datatypes Release 2.  At present, there is not an OWL&#x0a;
  - representation of these datatypes available, though producing one is a possible next step in enhancing&#x0a;
  - the OWL representation of BRIDG.&#x0a;
  -&#x0a;
  - BRIDG includes a number of constraints on its classes.  At present, these are represented as free text.&#x0a;
  - Future versions of BRIDG may express these constraints more formally within the ontology, where OWL&#x0a;
  - semantics allow.&#x0a;   '"/>
    <xsl:text>&#x0a;</xsl:text>
    <owl:Ontology ontologyIRI="http://www.bridgmodel.org/owl#" versionIRI="http://www.bridgmodel.org/owl/{$version}#">
      <xsl:call-template name="headerContent"/>
      <xsl:call-template name="datatypeContent"/>
      <xsl:call-template name="packageContent"/>
      <xsl:call-template name="classContent"/>
      <xsl:call-template name="propertyContent"/>
      <xsl:call-template name="attributeContent"/>
      <xsl:call-template name="associationContent"/>
    </owl:Ontology>
  </xsl:template>
  <xsl:template name="headerContent" as="node()+">
    <owl:Prefix name="owl" IRI="http://www.w3.org/2002/07/owl#"/>
    <owl:Prefix name="rdf" IRI="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
    <owl:Prefix name="rdfs" IRI="http://www.w3.org/2000/01/rdf-schema#"/>
    <owl:Prefix name="xs" IRI="http://www.w3.org/2001/XMLSchema"/>
    <owl:Prefix name="dct" IRI="http://purl.org/dc/terms/"/>
    <owl:Prefix name="foaf" IRI="http://xmlns.com/foaf/0.1/"/>
    <owl:Prefix name="skos" IRI="http://www.w3.org/2004/02/skos/core#"/>
    <owl:Prefix name="bridg" IRI="http://www.bridgmodel.org/owl#"/>
    <owl:Prefix name="dt" IRI="http://www.hl7.org/owl/iso-dt-2.0#"/>
    <owl:Import>http://purl.org/dc/terms/</owl:Import>
    <owl:Import>http://xmlns.com/foaf/0.1/</owl:Import>
    <owl:Import>http://www.w3.org/2004/02/skos/core#</owl:Import>
    <xsl:text disable-output-escaping="yes">&#x0a;  &lt;!-- Will include this once OWL for datatypes is available.  The URI may changes.&#x0a;  </xsl:text>
    <owl:import>http://www.hl7.org/owl/iso-dt-2.0#</owl:import>
    <xsl:text disable-output-escaping="yes">&#x0a;  --&gt;&#x0a;</xsl:text>
    <xsl:comment select="'&#x0a;    - BRIDG metadata&#x0a;    '"/>
    <xsl:if test="$includeAnnotations">
      <xsl:for-each select="xmi:XMI/xmi:Extension/elements/element[@name=$rootPackage]/tags">
        <xsl:for-each select="tag[@name='Replaces Version']">
          <owl:Annotation>
            <owl:AnnotationProperty abbreviatedIRI="owl:priorVersion"/>
            <owl:IRI>
              <xsl:value-of select="concat('http://www.bridgmodel.org/owl/', @value, '#')"/>
            </owl:IRI>
          </owl:Annotation>
        </xsl:for-each>
        <xsl:for-each select="tag[@name='Release Date']">
          <owl:Annotation>
            <owl:AnnotationProperty abbreviatedIRI="dct:issued"/>
            <owl:Literal datatypeIRI="xs:date">
              <xsl:value-of select="@value"/>
            </owl:Literal>
          </owl:Annotation>
        </xsl:for-each>
      </xsl:for-each>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:label"/>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Biomedical Research Integrated Domain Group (BRIDG) Domain Analysis Model</owl:Literal>
      </owl:Annotation>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="dct:type"/>
        <owl:IRI>http://purl.org/dc/dcmitype/Dataset</owl:IRI>
      </owl:Annotation>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="dct:language"/>
        <owl:Literal datatypeIRI="xs:string">en-US</owl:Literal>
      </owl:Annotation>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="dct:description"/>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">The Biomedical Research Integrated Domain Group (BRIDG) Model is a collaborative effort . The BRIDG model is an instance of a Domain Analysis Model (DAM). The goal of the BRIDG Model is to produce a shared view of the dynamic and static semantics for the domain of protocol-driven research and its associated regulatory artifacts. This domain of interest is further defined as:
    
    Protocol-driven research and its associated regulatory artifacts: i.e. the data, organization, resources, rules, and processes involved in the formal assessment of the utility, impact, or other pharmacological, physiological, or psychological effects of a drug, procedure, process, or device on a human, animal, or other subject or substance plus all associated regulatory artifacts required for or derived from this effort, including data specifically associated with post-marketing adverse event reporting.</owl:Literal>
      </owl:Annotation>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:seeAlso"/>
        <owl:IRI>http://www.bridgmodel.org</owl:IRI>
      </owl:Annotation>
      <xsl:text disable-output-escaping="yes">&#x0a;  &lt;!-- Consider adding this in the future&#x0a;  </xsl:text>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="dct:license"/>
        <owl:Literal>???</owl:Literal>
      </owl:Annotation>
      <xsl:text disable-output-escaping="yes">&#x0a;    --&gt;&#x0a;</xsl:text>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="dct:publisher"/>
        <owl:AnonymousIndividual nodeID="SCC"/>
      </owl:Annotation>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="dct:contributor"/>
        <owl:AnonymousIndividual nodeID="CDISC"/>
      </owl:Annotation>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="dct:contributor"/>
        <owl:AnonymousIndividual nodeID="RCRIM"/>
      </owl:Annotation>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="dct:contributor"/>
        <owl:AnonymousIndividual nodeID="FDA"/>
      </owl:Annotation>
      <owl:Annotation>
        <owl:AnnotationProperty abbreviatedIRI="dct:contributor"/>
        <owl:AnonymousIndividual nodeID="NCI"/>
      </owl:Annotation>
      <xsl:comment select="' SCC '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:ClassAssertion>
        <owl:Class abbreviatedIRI="foaf:Organization"/>
        <owl:AnonymousIndividual nodeID="SCC"/>
      </owl:ClassAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:name"/>
        <owl:AnonymousIndividual nodeID="SCC"/>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">BRIDG Semantic Coordination Committee (SCC)</owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:mbox"/>
        <owl:AnonymousIndividual nodeID="SCC"/>
        <owl:IRI>mailto:bridgTHC-L@list.nih.gov</owl:IRI>
      </owl:AnnotationAssertion>
      <xsl:comment select="' CDISC '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:ClassAssertion>
        <owl:Class abbreviatedIRI="foaf:Organization"/>
        <owl:AnonymousIndividual nodeID="CDISC"/>
      </owl:ClassAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:name"/>
        <owl:AnonymousIndividual nodeID="CDISC"/>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Clinical Data Interchange Standards Consortium (CDISC)</owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:homepage"/>
        <owl:AnonymousIndividual nodeID="CDISC"/>
        <owl:IRI>http://www.cdisc.org</owl:IRI>
      </owl:AnnotationAssertion>
      <xsl:comment select="' RCRIM '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:ClassAssertion>
        <owl:Class abbreviatedIRI="foaf:Organization"/>
        <owl:AnonymousIndividual nodeID="RCRIM"/>
      </owl:ClassAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:name"/>
        <owl:AnonymousIndividual nodeID="RCRIM"/>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Health Level Seven (HL7), Regulated Clinical Research Information Management (RCRIM) work group</owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:homepage"/>
        <owl:AnonymousIndividual nodeID="RCRIM"/>
        <owl:IRI>http://www.hl7.org/Special/committees/rcrim/index.cfm</owl:IRI>
      </owl:AnnotationAssertion>
      <xsl:comment select="' FDA '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:ClassAssertion>
        <owl:Class abbreviatedIRI="foaf:Organization"/>
        <owl:AnonymousIndividual nodeID="FDA"/>
      </owl:ClassAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:name"/>
        <owl:AnonymousIndividual nodeID="FDA"/>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">U.S. Food and Drug Administration (FDA)</owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:homepage"/>
        <owl:AnonymousIndividual nodeID="FDA"/>
        <owl:IRI>http://nci.nih.gov</owl:IRI>
      </owl:AnnotationAssertion>
      <xsl:comment select="' NCI '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:ClassAssertion>
        <owl:Class abbreviatedIRI="foaf:Organization"/>
        <owl:AnonymousIndividual nodeID="NCI"/>
      </owl:ClassAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:name"/>
        <owl:AnonymousIndividual nodeID="NCI"/>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">U.S. National Cancer Institute (NCI)</owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="foaf:homepage"/>
        <owl:AnonymousIndividual nodeID="NCI"/>
        <owl:IRI>http://www.fda.gov</owl:IRI>
      </owl:AnnotationAssertion>
    </xsl:if>
    <xsl:comment select="'&#x0a;    - Metadata structures&#x0a;    '"/>
    <owl:DisjointClasses>
      <owl:Class abbreviatedIRI="bridg:SubDomain"/>
      <owl:Class abbreviatedIRI="bridg:DataEntity"/>
    </owl:DisjointClasses>
    <xsl:comment select="' Entity '"/>
    <xsl:text>&#x0a;  </xsl:text>
    <owl:SubClassOf>
      <owl:Class abbreviatedIRI="bridg:DataEntity"/>
      <owl:Class abbreviatedIRI="owl:Thing"/>
    </owl:SubClassOf>
    <xsl:if test="$includeAnnotations">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:DataEntity</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Abstract construct collecting all BRIDG classes together</owl:Literal>
      </owl:AnnotationAssertion>
    </xsl:if>
    <xsl:comment select="' SubDomain '"/>
    <xsl:text>&#x0a;  </xsl:text>
    <owl:SubClassOf>
      <owl:Class abbreviatedIRI="bridg:SubDomain"/>
      <owl:Class abbreviatedIRI="owl:Thing"/>
    </owl:SubClassOf>
    <xsl:if test="$includeAnnotations">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:SubDomain</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Abstract construct collecting all BRIDG packages together</owl:Literal>
      </owl:AnnotationAssertion>
    </xsl:if>
    <xsl:comment select="'entityProperty'"/>
    <xsl:text>&#x0a;  </xsl:text>
    <owl:SubObjectPropertyOf>
      <owl:ObjectProperty abbreviatedIRI="bridg:entityProperty"/>
      <owl:ObjectProperty abbreviatedIRI="owl:topObjectProperty"/>
    </owl:SubObjectPropertyOf>
    <xsl:if test="$includeAnnotations">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:entityProperty</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Grouper for attribute and association for situations where either may apply.</owl:Literal>
      </owl:AnnotationAssertion>
    </xsl:if>
    <owl:ObjectPropertyDomain>
      <owl:ObjectProperty abbreviatedIRI="bridg:entityProperty"/>
      <owl:Class abbreviatedIRI="bridg:DataEntity"/>
    </owl:ObjectPropertyDomain>
    <xsl:comment select="' attribute '"/>
    <xsl:text>&#x0a;  </xsl:text>
    <owl:SubObjectPropertyOf>
      <owl:ObjectProperty abbreviatedIRI="bridg:attributeProperty"/>
      <owl:ObjectProperty abbreviatedIRI="bridg:entityProperty"/>
    </owl:SubObjectPropertyOf>
    <owl:ObjectPropertyRange>
      <owl:ObjectProperty abbreviatedIRI="bridg:attributeProperty"/>
      <owl:Class abbreviatedIRI="dt:ANY"/>
    </owl:ObjectPropertyRange>
    <xsl:if test="$includeAnnotations">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:attributeProperty</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Represents attributes of BRIDG classes</owl:Literal>
      </owl:AnnotationAssertion>
    </xsl:if>
    <xsl:comment select="' association '"/>
    <xsl:text>&#x0a;  </xsl:text>
    <owl:SubObjectPropertyOf>
      <owl:ObjectProperty abbreviatedIRI="bridg:associationProperty"/>
      <owl:ObjectProperty abbreviatedIRI="bridg:entityProperty"/>
    </owl:SubObjectPropertyOf>
    <xsl:if test="$includeAnnotations">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:associationProperty</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Represents associations between BRIDG classes</owl:Literal>
      </owl:AnnotationAssertion>
    </xsl:if>
    <owl:ObjectPropertyRange>
      <owl:ObjectProperty abbreviatedIRI="bridg:associationProperty"/>
      <owl:Class abbreviatedIRI="bridg:DataEntity"/>
    </owl:ObjectPropertyRange>
    <xsl:if test="$includeAnnotations">
      <xsl:comment select="' isAbstract '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:SubAnnotationPropertyOf>
        <owl:AnnotationProperty abbreviatedIRI="bridg:isAbstract"/>
        <owl:AnnotationProperty abbreviatedIRI="owl:topAnnotationProperty"/>
      </owl:SubAnnotationPropertyOf>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:isAbstract</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Identifies whether a class is considered "abstract" (i.e. not directly instantiatable)</owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationPropertyDomain>
        <owl:AnnotationProperty abbreviatedIRI="bridg:isAbstract"/>
        <owl:AbbreviatedIRI>bridg:DataEntity</owl:AbbreviatedIRI>
      </owl:AnnotationPropertyDomain>
      <owl:AnnotationPropertyRange>
        <owl:AnnotationProperty abbreviatedIRI="bridg:isAbstract"/>
        <owl:AbbreviatedIRI>xs:boolean</owl:AbbreviatedIRI>
      </owl:AnnotationPropertyRange>
      <xsl:comment select="' isDerived '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:SubAnnotationPropertyOf>
        <owl:AnnotationProperty abbreviatedIRI="bridg:isDerived"/>
        <owl:AnnotationProperty abbreviatedIRI="owl:topAnnotationProperty"/>
      </owl:SubAnnotationPropertyOf>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:isDerived</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Identifies whether a the semantics of a given attribute or association can be determined from other characteristics in the model.  (At some point, these derivations might be formally expressed in OWL semantics.)</owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationPropertyDomain>
        <owl:AnnotationProperty abbreviatedIRI="bridg:isDerived"/>
        <owl:AbbreviatedIRI>bridg:entityProperty</owl:AbbreviatedIRI>
      </owl:AnnotationPropertyDomain>
      <owl:AnnotationPropertyRange>
        <owl:AnnotationProperty abbreviatedIRI="bridg:isDerived"/>
        <owl:AbbreviatedIRI>xs:boolean</owl:AbbreviatedIRI>
      </owl:AnnotationPropertyRange>
      <xsl:comment select="' associationType '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:DatatypeDefinition>
        <owl:Datatype abbreviatedIRI="bridg:associationTypeDatatype"/>
        <owl:DataOneOf>
          <owl:Literal datatypeIRI="xs:NMTOKEN" xml:lang="en-US">none</owl:Literal>
          <owl:Literal datatypeIRI="xs:NMTOKEN" xml:lang="en-US">shared</owl:Literal>
          <owl:Literal datatypeIRI="xs:NMTOKEN" xml:lang="en-US">composite</owl:Literal>
        </owl:DataOneOf>
      </owl:DatatypeDefinition>
      <owl:SubAnnotationPropertyOf>
        <owl:AnnotationProperty abbreviatedIRI="bridg:associationType"/>
        <owl:AnnotationProperty abbreviatedIRI="owl:topAssociationProperty"/>
      </owl:SubAnnotationPropertyOf>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:associationType</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Indicates the type of UML aggregation charactersitics an association shows</owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationPropertyDomain>
        <owl:AnnotationProperty abbreviatedIRI="bridg:associationType"/>
        <owl:AbbreviatedIRI>bridg:association</owl:AbbreviatedIRI>
      </owl:AnnotationPropertyDomain>
      <owl:AnnotationPropertyRange>
        <owl:AnnotationProperty abbreviatedIRI="bridg:associationType"/>
        <owl:AbbreviatedIRI>bridg:associationTypeDatatype</owl:AbbreviatedIRI>
      </owl:AnnotationPropertyRange>
      <xsl:comment select="' roleName '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:SubAnnotationPropertyOf>
        <owl:AnnotationProperty abbreviatedIRI="bridg:roleName"/>
        <owl:AnnotationProperty abbreviatedIRI="owl:topAnnotationProperty"/>
      </owl:SubAnnotationPropertyOf>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:roleName</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Indicates the role name when traversing the association to the target class</owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationPropertyDomain>
        <owl:AnnotationProperty abbreviatedIRI="bridg:roleName"/>
        <owl:AbbreviatedIRI>bridg:association</owl:AbbreviatedIRI>
      </owl:AnnotationPropertyDomain>
      <owl:AnnotationPropertyRange>
        <owl:AnnotationProperty abbreviatedIRI="bridg:roleName"/>
        <owl:AbbreviatedIRI>xs:string</owl:AbbreviatedIRI>
      </owl:AnnotationPropertyRange>
      <xsl:comment select="' constraint '"/>
      <xsl:text>&#x0a;  </xsl:text>
      <owl:SubAnnotationPropertyOf>
        <owl:AnnotationProperty abbreviatedIRI="bridg:constraint"/>
        <owl:AnnotationProperty abbreviatedIRI="skos:note"/>
      </owl:SubAnnotationPropertyOf>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
        <owl:AbbreviatedIRI>bridg:constraint</owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">Identifies a constraint that applies within the context of a class</owl:Literal>
      </owl:AnnotationAssertion>
    </xsl:if>
  </xsl:template>
  <xsl:template name="datatypeContent" as="node()+">
    <xsl:comment select="'&#x0a;    - Datatypes&#x0a;    '"/>
    <owl:Declaration>
      <owl:Class abbreviatedIRI="dt:HL7AbstractDatatype"/>
    </owl:Declaration>
    <xsl:for-each select="distinct-values(/xmi:XMI/xmi:Extension/elements/element[model/@package=$modelPackages]/attributes/attribute/properties/@type)">
      <xsl:sort select="."/>
      <owl:SubClassOf>
        <owl:Class abbreviatedIRI="dt:{translate(., '&lt;,&gt; ', '__')}"/>
        <owl:Class abbreviatedIRI="dt:HL7AbstractDatatype"/>
      </owl:SubClassOf>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="packageContent" as="node()+">
    <xsl:comment select="'&#x0a;    - Packages&#x0a;    '"/>
    <xsl:apply-templates mode="Package" select="xmi:XMI/uml:Model//packagedElement[@name=$rootPackage]"/>
  </xsl:template>
  <xsl:template mode="Package" match="packagedElement">
    <xsl:variable name="escapedName" as="xs:string" select="bridg:escapeName(@name)"/>
    <xsl:comment select="concat('Package: ', @name)"/>
    <owl:ClassAssertion>
      <owl:Class abbreviatedIRI="bridg:SubDomain"/>
      <owl:NamedIndividual abbreviatedIRI="bridg:{$escapedName}"/>
    </owl:ClassAssertion>
    <xsl:if test="parent::packagedElement and not(@name=$rootPackage)">
      <owl:ObjectPropertyAssertion>
        <owl:ObjectProperty abbreviatedIRI="dct:isPartOf"/>
        <owl:NamedIndividual abbreviatedIRI="bridg:{$escapedName}"/>
        <owl:NamedIndividual abbreviatedIRI="bridg:{bridg:escapeName(parent::packagedElement/@name)}"/>
      </owl:ObjectPropertyAssertion>
    </xsl:if>
    <xsl:if test="$includeAnnotations">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:label"/>
        <owl:AbbreviatedIRI>
          <xsl:value-of select="concat('bridg:', $escapedName)"/>
        </owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
          <xsl:value-of select="@name"/>
        </owl:Literal>
      </owl:AnnotationAssertion>
      <xsl:for-each select="ownedComment[not(annotatedElement)]">
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $escapedName)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
            <xsl:value-of select="@body"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="count(packagedElement[@xmi:type='uml:Package'])&gt;1">
      <owl:DifferentIndividuals>
        <xsl:for-each select="packagedElement[@xmi:type='uml:Package']">
          <xsl:sort select="@name"/>
          <owl:NamedIndividual abbreviatedIRI="bridg:{bridg:escapeName(@name)}"/>
        </xsl:for-each>
      </owl:DifferentIndividuals>
      <xsl:apply-templates mode="Package" select="packagedElement[@xmi:type='uml:Package']"/>
    </xsl:if>
  </xsl:template>
  <xsl:template name="classContent" as="node()+">
    <xsl:comment select="'&#x0a;    - Entities&#x0a;    '"/>
    <!-- All classes with no parent are disjoint -->
    <owl:DisjointClasses>
      <xsl:for-each select="/xmi:XMI/xmi:Extension/elements/element[model/@package=$modelPackages][@xmi:type='uml:Class'][not(links/Generalization)]">
        <xsl:sort select="@name"/>
        <owl:Class abbreviatedIRI="bridg:{@name}"/>
      </xsl:for-each>
    </owl:DisjointClasses>
    <owl:DifferentIndividuals>
      <xsl:for-each select="/xmi:XMI/xmi:Extension/elements/element[model/@package=$modelPackages][@xmi:type='uml:Class'][not(links/Generalization)]">
        <xsl:sort select="@name"/>
        <owl:NamedIndividual abbreviatedIRI="bridg:{@name}"/>
      </xsl:for-each>
    </owl:DifferentIndividuals>
    <xsl:for-each select="/xmi:XMI/xmi:Extension/elements/element[model/@package=$modelPackages][@xmi:type='uml:Class']">
      <xsl:sort select="@name"/>
      <xsl:apply-templates mode="Class" select="."/>
    </xsl:for-each>
  </xsl:template>
  <xsl:template mode="Class" match="element">
    <xsl:variable name="name" select="@name"/>
    <xsl:comment select="$name"/>
    <owl:ClassAssertion>
      <owl:Class abbreviatedIRI="bridg:DataEntity"/>
      <owl:NamedIndividual abbreviatedIRI="bridg:{$name}"/>
    </owl:ClassAssertion>
    <owl:SubClassOf>
      <owl:Class abbreviatedIRI="bridg:{$name}"/>
      <xsl:variable name="classes" as="element()+">
        <xsl:choose>
          <xsl:when test="links/Generalization[@end!=current()/@xmi:idref]">
            <owl:Class abbreviatedIRI="bridg:{key('elementById', links/Generalization[@end!=current()/@xmi:idref]/@end)/@name}"/>
          </xsl:when>
          <xsl:otherwise>
            <owl:Class abbreviatedIRI="bridg:DataEntity"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="attributes/attribute">
          <xsl:sort select="@name"/>
          <!-- While the UML specifies a default lower-bound cardinality of 1, this isn't actually what's intended -->
          <owl:ObjectMinCardinality cardinality="0">
            <owl:ObjectProperty abbreviatedIRI="bridg:{$name}.{@name}"/>
          </owl:ObjectMinCardinality>
          <!-- Repeating attributes repeat *inside* the collection type, and the collection type itself has a cardinality of 1, so the upper bound is always 1. -->
          <owl:ObjectMaxCardinality cardinality="1">
            <owl:ObjectProperty abbreviatedIRI="bridg:{$name}.{@name}"/>
          </owl:ObjectMaxCardinality>
        </xsl:for-each>
        <xsl:for-each select="/xmi:XMI/xmi:Extension/connectors/connector[not(properties/@ea_type=('NoteLink', 'Generalization', 'Realisation'))][source/@xmi:idref=current()/@xmi:idref]">
          <xsl:sort select="target/role/@name"/>
          <owl:ObjectMinCardinality cardinality="{bridg:lower-bound(target/type/@multiplicity)}">
            <owl:ObjectProperty abbreviatedIRI="bridg:{$name}.{bridg:escapeName(target/role/@name)}"/>
          </owl:ObjectMinCardinality>
          <xsl:variable name="upperMultiplicity" as="xs:string" select="bridg:upper-bound(target/type/@multiplicity)"/>
          <xsl:if test="$upperMultiplicity!='*'">
            <owl:ObjectMaxCardinality cardinality="{$upperMultiplicity}">
              <owl:ObjectProperty abbreviatedIRI="bridg:{$name}.{bridg:escapeName(target/role/@name)}"/>
            </owl:ObjectMaxCardinality>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="/xmi:XMI/xmi:Extension/connectors/connector[not(properties/@ea_type=('NoteLink', 'Generalization', 'Realisation'))][target/@xmi:idref=current()/@xmi:idref]">
          <xsl:sort select="source/role/@name"/>
          <owl:ObjectMinCardinality cardinality="{bridg:lower-bound(source/type/@multiplicity)}">
            <owl:ObjectProperty abbreviatedIRI="bridg:{$name}.{bridg:escapeName(source/role/@name)}"/>
          </owl:ObjectMinCardinality>
          <xsl:variable name="upperMultiplicity" as="xs:string" select="bridg:upper-bound(source/type/@multiplicity)"/>
          <xsl:if test="$upperMultiplicity!='*'">
            <owl:ObjectMaxCardinality cardinality="{$upperMultiplicity}">
              <owl:ObjectProperty abbreviatedIRI="bridg:{$name}.{bridg:escapeName(source/role/@name)}"/>
            </owl:ObjectMaxCardinality>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="count($classes)=1">
          <xsl:copy-of select="$classes"/>
        </xsl:when>
        <xsl:otherwise>
          <owl:ObjectIntersectionOf>
            <xsl:copy-of select="$classes"/>
          </owl:ObjectIntersectionOf>
        </xsl:otherwise>
      </xsl:choose>
    </owl:SubClassOf>
    <owl:ObjectPropertyAssertion>
      <owl:ObjectProperty abbreviatedIRI="dct:isPartOf"/>
      <owl:NamedIndividual abbreviatedIRI="bridg:{$name}"/>
      <owl:NamedIndividual abbreviatedIRI="bridg:{bridg:escapeName(key('elementById', model/@package)/@name)}"/>
    </owl:ObjectPropertyAssertion>
    <xsl:if test="$includeAnnotations">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="rdfs:label"/>
        <owl:AbbreviatedIRI>
          <xsl:value-of select="concat('bridg:', $name)"/>
        </owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
          <xsl:value-of select="@name"/>
        </owl:Literal>
      </owl:AnnotationAssertion>
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="bridg:isAbstract"/>
        <owl:AbbreviatedIRI>
          <xsl:value-of select="concat('bridg:', $name)"/>
        </owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:boolean">
          <xsl:value-of select="properties/@isAbstract"/>
        </owl:Literal>
      </owl:AnnotationAssertion>
      <xsl:call-template name="doDocumentation">
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="documentationStr" select="properties/@documentation"/>
      </xsl:call-template>
      <xsl:for-each select="//ownedComment[annotatedElement/@xmi:idref=current()/@xmi:idref]">
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $name)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
            <xsl:value-of select="@body"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
      </xsl:for-each>
      <xsl:for-each select="constraints/constraint">
        <xsl:sort select="@name"/>
        <owl:AnnotationAssertion>
          <owl:Annotation>
            <owl:AnnotationProperty abbreviatedIRI="rdfs:label"/>
            <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
              <xsl:value-of select="@name"/>
            </owl:Literal>
          </owl:Annotation>
          <owl:AnnotationProperty abbreviatedIRI="bridg:constraint"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $name)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
            <xsl:value-of select="@description"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
      </xsl:for-each>
      <xsl:call-template name="doTags">
        <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
    </xsl:if>
    <!-- All classes with this class as a parent -->
    <xsl:if test="count(/xmi:XMI/uml:Model//packagedElement[generalization[@general=current()/@xmi:idref]])&gt;1">
      <owl:DisjointClasses>
        <xsl:for-each select="/xmi:XMI/uml:Model//packagedElement[generalization[@general=current()/@xmi:idref]]">
          <xsl:sort select="@name"/>
          <owl:Class abbreviatedIRI="bridg:{@name}"/>
        </xsl:for-each>
      </owl:DisjointClasses>
    </xsl:if>
  </xsl:template>
  <xsl:template name="propertyContent" as="node()+">
    <xsl:comment select="'&#x0a;    - Attributes and Associations&#x0a;    '"/>
    <owl:DisjointObjectProperties>
      <xsl:variable name="properties" as="xs:string+">
        <xsl:for-each select="/xmi:XMI/xmi:Extension/elements/element[model/@package=$modelPackages]/attributes/attribute">
          <xsl:value-of select="concat(parent::attributes/parent::element/@name, '.', @name)"/>
        </xsl:for-each>
        <xsl:for-each select="/xmi:XMI/xmi:Extension/connectors/connector[exists(key('classById', source/@xmi:idref)) and exists(key('classById', target/@xmi:idref))][not(properties/@ea_type=('NoteLink', 'Generalization', 'Realisation'))]">
          <xsl:value-of select="concat(source/model/@name, '.', bridg:escapeName(target/role/@name))"/>
          <xsl:value-of select="concat(target/model/@name, '.', bridg:escapeName(source/role/@name))"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:for-each select="$properties">
        <xsl:sort select="."/>
        <owl:ObjectProperty abbreviatedIRI="bridg:{.}"/>
      </xsl:for-each>
    </owl:DisjointObjectProperties>
  </xsl:template>
  <xsl:template name="attributeContent" as="node()+">
    <xsl:comment select="'&#x0a;    - Attributes&#x0a;    '"/>
    <xsl:for-each select="/xmi:XMI/xmi:Extension/elements/element[model/@package=$modelPackages]/attributes/attribute">
      <xsl:sort select="parent::attributes/parent::element/@name"/>
      <xsl:sort select="@name"/>
      <xsl:variable name="className" as="xs:string" select="parent::attributes/parent::element/@name"/>
      <xsl:variable name="name" as="xs:string" select="concat($className, '.', @name)"/>
      <xsl:comment select="$name"/>
      <owl:SubObjectPropertyOf>
        <owl:ObjectProperty abbreviatedIRI="bridg:{$name}"/>
        <owl:ObjectProperty abbreviatedIRI="bridg:attributeProperty"/>
      </owl:SubObjectPropertyOf>
      <owl:ObjectPropertyDomain>
        <owl:ObjectProperty abbreviatedIRI="bridg:{$name}"/>
        <owl:Class abbreviatedIRI="bridg:{$className}"/>
      </owl:ObjectPropertyDomain>
      <owl:ObjectPropertyRange>
        <owl:ObjectProperty abbreviatedIRI="bridg:{$name}"/>
        <owl:Class abbreviatedIRI="{concat('dt:', translate(properties/@type, '&lt;,&gt; ', '__'))}"/>
      </owl:ObjectPropertyRange>
      <xsl:if test="$includeAnnotations">
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="rdfs:label"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $name)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
            <xsl:value-of select="@name"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="bridg:isDerived"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $name)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:boolean">
            <xsl:value-of select="if (properties/@derived=1) then 'true' else 'false'"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
        <xsl:call-template name="doDocumentation">
          <xsl:with-param name="name" select="$name"/>
          <xsl:with-param name="documentationStr" select="documentation/@value"/>
        </xsl:call-template>
        <xsl:call-template name="doTags">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="associationContent" as="node()+">
    <xsl:comment>&#x0a;    - Associations&#x0a;    </xsl:comment>
    <xsl:for-each select="/xmi:XMI/xmi:Extension/connectors/connector[exists(key('classById', source/@xmi:idref)) and exists(key('classById', target/@xmi:idref))][not(properties/@ea_type=('NoteLink', 'Generalization', 'Realisation'))]">
      <xsl:sort select="source/model/@name"/>
      <xsl:sort select="target/role/@name"/>
      <xsl:variable name="name" as="xs:string" select="bridg:escapeName(concat(source/model/@name, '.', target/role/@name))"/>
      <xsl:variable name="inverseName" as="xs:string" select="bridg:escapeName(concat(target/model/@name, '.', source/role/@name))"/>
      <xsl:comment select="$name"/>
      <owl:SubObjectPropertyOf>
        <owl:ObjectProperty abbreviatedIRI="bridg:{$name}"/>
        <owl:ObjectProperty abbreviatedIRI="bridg:associationProperty"/>
      </owl:SubObjectPropertyOf>
      <owl:ObjectPropertyDomain>
        <owl:ObjectProperty abbreviatedIRI="bridg:{$name}"/>
        <owl:Class abbreviatedIRI="bridg:{source/model/@name}"/>
      </owl:ObjectPropertyDomain>
      <owl:ObjectPropertyRange>
        <owl:ObjectProperty abbreviatedIRI="bridg:{$name}"/>
        <owl:Class abbreviatedIRI="bridg:{target/model/@name}"/>
      </owl:ObjectPropertyRange>
      <xsl:if test="$includeAnnotations">
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="rdfs:label"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $name)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
            <xsl:value-of select="labels/@mt"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="bridg:associationType"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $name)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string">
            <xsl:value-of select="target/type/@aggregation"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="bridg:roleName"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $name)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string">
            <xsl:value-of select="target/role/@name"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="bridg:isDerived"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $name)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:boolean">
            <xsl:value-of select="if (contains(xrefs/@value, '@PROP=@NAME=isDerived@ENDNAME;@TYPE=Boolean@ENDTYPE;@VALU=true@ENDVALU;')) then 'true' else 'false'"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
        <xsl:call-template name="doDocumentation">
          <xsl:with-param name="name" select="$name"/>
          <xsl:with-param name="documentationStr" select="documentation/@value"/>
        </xsl:call-template>
        <xsl:call-template name="doTags">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
      </xsl:if>
      <owl:SubObjectPropertyOf>
        <owl:ObjectProperty abbreviatedIRI="bridg:{$inverseName}"/>
        <owl:ObjectProperty abbreviatedIRI="bridg:associationProperty"/>
      </owl:SubObjectPropertyOf>
      <owl:InverseObjectProperties>
        <owl:ObjectProperty abbreviatedIRI="bridg:{$name}"/>
        <owl:ObjectProperty abbreviatedIRI="bridg:{$inverseName}"/>
      </owl:InverseObjectProperties>
      <xsl:if test="$includeAnnotations">
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="rdfs:label"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $inverseName)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
            <xsl:value-of select="constraints/constraint[@type='Inverse Relation']/@name"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="bridg:associationType"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $inverseName)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string">
            <xsl:value-of select="source/type/@aggregation"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
        <owl:AnnotationAssertion>
          <owl:AnnotationProperty abbreviatedIRI="bridg:roleName"/>
          <owl:AbbreviatedIRI>
            <xsl:value-of select="concat('bridg:', $inverseName)"/>
          </owl:AbbreviatedIRI>
          <owl:Literal datatypeIRI="xs:string">
            <xsl:value-of select="source/role/@name"/>
          </owl:Literal>
        </owl:AnnotationAssertion>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="doDocumentation" as="element(owl:AnnotationAssertion)+">
    <xsl:param name="name" as="xs:string" required="yes"/>
    <xsl:param name="documentationStr" as="xs:string" required="yes"/>
    <xsl:variable name="documentation" as="element(documentation)">
      <xsl:call-template name="parseDocumentation">
        <xsl:with-param name="documentation" select="$documentationStr"/>
      </xsl:call-template>
    </xsl:variable>
    <owl:AnnotationAssertion>
      <owl:AnnotationProperty abbreviatedIRI="skos:definition"/>
      <owl:AbbreviatedIRI>
        <xsl:value-of select="concat('bridg:', $name)"/>
      </owl:AbbreviatedIRI>
      <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
        <xsl:value-of select="$documentation/definition"/>
      </owl:Literal>
    </owl:AnnotationAssertion>
    <xsl:for-each select="$documentation/example">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="skos:example"/>
        <owl:AbbreviatedIRI>
          <xsl:value-of select="concat('bridg:', $name)"/>
        </owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
          <xsl:value-of select="."/>
        </owl:Literal>
      </owl:AnnotationAssertion>
    </xsl:for-each>
    <xsl:for-each select="$documentation/otherName">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="skos:altLabel"/>
        <owl:AbbreviatedIRI>
          <xsl:value-of select="concat('bridg:', $name)"/>
        </owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
          <xsl:value-of select="."/>
        </owl:Literal>
      </owl:AnnotationAssertion>
    </xsl:for-each>
    <xsl:for-each select="$documentation/notes">
      <owl:AnnotationAssertion>
        <owl:AnnotationProperty abbreviatedIRI="skos:note"/>
        <owl:AbbreviatedIRI>
          <xsl:value-of select="concat('bridg:', $name)"/>
        </owl:AbbreviatedIRI>
        <owl:Literal datatypeIRI="xs:string" xml:lang="en-US">
          <xsl:value-of select="."/>
        </owl:Literal>
      </owl:AnnotationAssertion>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="parseDocumentation" as="element(documentation)">
    <xsl:param name="documentation" as="xs:string" required="yes"/>
    <documentation>
      <xsl:variable name="definition" as="xs:string" select="bridg:trim(substring-before(substring-after($documentation, 'DEFINITION:'), 'EXAMPLE(S):'))"/>
      <xsl:variable name="examples" as="xs:string" select="translate(bridg:trim(substring-before(substring-after($documentation, 'EXAMPLE(S):'), 'OTHER NAME(S):')), '&#x0a;', ',')"/>
      <xsl:variable name="otherNames" as="xs:string" select="translate(bridg:trim(substring-before(substring-after($documentation, 'OTHER NAME(S):'), 'NOTE(S):')), '&#x0a;', ',')"/>
      <xsl:variable name="notes" as="xs:string" select="bridg:trim(substring-after($documentation, 'NOTE(S):'))"/>
      <xsl:if test="$definition!=''">
        <definition>
          <xsl:value-of select="$definition"/>
        </definition>
      </xsl:if>
      <xsl:for-each select="tokenize($examples, ',')">
        <xsl:variable name="example" as="xs:string" select="normalize-space(.)"/>
        <xsl:if test="$example!=''">
          <example>
            <xsl:value-of select="$example"/>
          </example>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="tokenize($otherNames, ',')">
        <xsl:variable name="otherName" as="xs:string" select="normalize-space(.)"/>
        <xsl:if test="$otherName!=''">
          <otherName>
            <xsl:value-of select="$otherName"/>
          </otherName>
        </xsl:if>
      </xsl:for-each>
      <xsl:if test="$notes!=''">
        <notes>
          <xsl:value-of select="$notes"/>
        </notes>
      </xsl:if>
    </documentation>
  </xsl:template>
  <xsl:template name="doTags" as="element(owl:AnnotationAssertion)*">
    <xsl:param name="name" as="xs:string" required="yes"/>
    <xsl:for-each select="tags/tag[starts-with(@name, 'Map:')]">
      <xsl:sort select="@name"/>
      <owl:AnnotationAssertion>
        <xsl:if test="contains(@value, '(')">
          <owl:Annotation>
            <owl:AnnotationProperty abbreviatedIRI="rdfs:comment"/>
            <owl:Literal datatypeIRI="xs:string">
              <xsl:value-of select="normalize-space(translate(substring-after(@value, '('), ')', ''))"/>
            </owl:Literal>
          </owl:Annotation>
        </xsl:if>
        <owl:AnnotationProperty abbreviatedIRI="skos:relatedMatch"/>
        <owl:AbbreviatedIRI>
          <xsl:value-of select="concat('bridg:', $name)"/>
        </owl:AbbreviatedIRI>
        <owl:IRI>
          <xsl:value-of select="bridg:escapeName(concat('urn:', normalize-space(substring-after(@name, 'Map:')), ':', normalize-space(if (contains(@value, '(')) then substring-before(@value, '(') else @value)))"/>
        </owl:IRI>
      </owl:AnnotationAssertion>
    </xsl:for-each>
  </xsl:template>
  <xsl:function name="bridg:escapeName" as="xs:string">
    <xsl:param name="baseName" as="xs:string"/>
    <xsl:value-of select="translate($baseName, ' &amp;&lt;&gt;&quot;,#=^%', '__________')"/>
  </xsl:function>
  <xsl:function name="bridg:lower-bound" as="xs:string">
    <xsl:param name="cardinality" as="xs:string"/>
    <xsl:value-of select="if (contains($cardinality, '..')) then substring-before($cardinality, '..') else $cardinality"/>
  </xsl:function>
  <xsl:function name="bridg:upper-bound" as="xs:string">
    <xsl:param name="cardinality" as="xs:string"/>
    <xsl:value-of select="if (contains($cardinality, '..')) then substring-after($cardinality, '..') else $cardinality"/>
  </xsl:function>
  <xsl:function name="bridg:trim" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="normalize-space($string)=''">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:when test="normalize-space(substring($string,1,1))=''">
        <xsl:value-of select="bridg:trim(substring($string,2))"/>
      </xsl:when>
      <xsl:when test="normalize-space(substring($string,string-length($string),1))=''">
        <xsl:value-of select="bridg:trim(substring($string,1, string-length($string)-1))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
