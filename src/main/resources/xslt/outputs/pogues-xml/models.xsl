<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
	xmlns:eno="http://xml.insee.fr/apps/eno"
	xmlns:enopogues="http://xml.insee.fr/apps/eno/pogues-xml"
	exclude-result-prefixes="xs xd eno enopogues" version="2.0">

	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p>An xslt stylesheet who transforms an input into Odt through generic driver templates.</xd:p>
			<xd:p>The real input is mapped with the drivers.</xd:p>
		</xd:desc>
	</xd:doc>
	
	<xsl:template match="Form" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:variable name="languages" select="enopogues:get-form-languages($source-context)" as="xs:string +"/>
		<xsl:variable name="id" select="substring-after(enopogues:get-name($source-context), '-')" />
		<Questionnaire id="{$id}" xmlns="http://xml.insee.fr/schema/applis/pogues" genericName="QUESTIONNAIRE" agency="fr.insee" final="false">
			<Name>---no-source-found!---</Name>
			<Label><xsl:value-of select="enopogues:get-label($source-context,$languages[1])"/></Label>
			<TargetMode>---no-source-found!---</TargetMode>
			<TargetMode>---no-source-found!---</TargetMode>
			<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
				<xsl:with-param name="driver" select="eno:append-empty-element('driver-Global', .)" tunnel="yes"/>
				<xsl:with-param name="language" select="$languages[1]" tunnel="yes"/>
			</xsl:apply-templates>
			<ComponentGroup id="---no-source-found!---">
				<Name>---no-source-found!---</Name>
				<Label>---no-source-found!---</Label>
				<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
					<xsl:with-param name="driver" select="eno:append-empty-element('driver-Component', .)" tunnel="yes"/>
				</xsl:apply-templates>
			</ComponentGroup>
			<CodeLists></CodeLists>
			<Variables>
				<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
					<xsl:with-param name="driver" select="eno:append-empty-element('driver-VariableScheme', .)" tunnel="yes"/>
					<xsl:with-param name="language" select="$languages[1]" tunnel="yes"/>
				</xsl:apply-templates>
			</Variables>
		</Questionnaire>
	</xsl:template>

	<xsl:template match="driver-Global//Module | driver-Global//SubModule" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="language" as="xs:string" tunnel="yes"/>
		<xsl:variable name="id" select="enopogues:get-name($source-context)" />
		<xsl:variable name="depth">
			<xsl:choose>
				<xsl:when test="self::Module">1</xsl:when>
				<xsl:otherwise>2</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="genericName">
			<xsl:choose>
				<xsl:when test="self::Module">MODULE</xsl:when>
				<xsl:otherwise>SUBMODULE</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<Child id="{$id}" depth="{$depth}" genericName="{$genericName}" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="SequenceType">	
			<Name><xsl:value-of select="enopogues:get-name-sequence($source-context)"/></Name>
			<xsl:choose>
				<xsl:when test="self::Module">
					<Label><xsl:value-of select="normalize-space(substring-after(enopogues:get-label($source-context,$language), '-'))"/></Label>
				</xsl:when>
				<xsl:otherwise>
					<Label><xsl:value-of select="enopogues:get-label($source-context,$language)"/></Label>
				</xsl:otherwise>
			</xsl:choose>
			<TargetMode>---no-source-found!---</TargetMode>
			<TargetMode>---no-source-found!---</TargetMode>
			<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
				<xsl:with-param name="language" select="$language" tunnel="yes"/>
			</xsl:apply-templates>
		</Child>
	</xsl:template>

	<xsl:template match="driver-Global//QuestionSimple" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="language" as="xs:string" tunnel="yes"/>
		<xsl:variable name="id" select="enopogues:get-name($source-context)"/>
		<Child id="{$id}" questionType="SIMPLE" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="QuestionType">
			<Name><xsl:value-of select="enopogues:get-question-name($source-context,$language)"/></Name>
			<Label><xsl:value-of select="normalize-space(substring-after(enopogues:get-label($source-context,$language), '.'))"/></Label>
			<TargetMode>---no-source-found!---</TargetMode>
			<TargetMode>---no-source-found!---</TargetMode>
			<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
				<!--<xsl:with-param name="id-question" select="$id" tunnel="yes"/>-->
			</xsl:apply-templates>
		</Child>
	</xsl:template>

	<xsl:template match="QuestionDynamicTable" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="language" as="xs:string" tunnel="yes"/>
		<xsl:variable name="id" select="enopogues:get-name($source-context)" />
		<xsl:variable name="minMaxLines" select="concat(enopogues:get-minimum-lines($source-context),'-',enopogues:get-maximum-lines($source-context))"/>
		<Child id="{$id}" questionType="TABLE" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="QuestionType">
			<Name><xsl:value-of select="enopogues:get-question-name($source-context,$language)"/></Name>
			<Label><xsl:value-of select="normalize-space(substring-after(enopogues:get-label($source-context,$language), '.'))"/></Label>
			<TargetMode>---no-source-found!---</TargetMode>
			<TargetMode>---no-source-found!---</TargetMode>
			<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
				<xsl:with-param name="language" select="$language" tunnel="yes"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
				<xsl:with-param name="driver" select="eno:append-empty-element('driver-ResponseStructure', .)" tunnel="yes"/>
				<xsl:with-param name="minMaxLines" select="$minMaxLines" tunnel="yes"/>
			</xsl:apply-templates>
		</Child>
	</xsl:template>

	<xsl:template match="driver-ResponseStructure/CodeDomainDimension" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="language" as="xs:string" tunnel="yes"/>
		<xsl:param name="minMaxLines" as="xs:string" tunnel="yes"/>
		<ResponseStructure>
			<Dimension dimensionType="PRIMARY" dynamic="{$minMaxLines}"/>
			<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
				<xsl:with-param name="driver" select="eno:append-empty-element('driver-CodeDomain', .)" tunnel="yes"/>
			</xsl:apply-templates>
		</ResponseStructure>
	</xsl:template>
	
	<xsl:template match="driver-CodeDomain/CodeDomain" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="language" as="xs:string" tunnel="yes"/>
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="eno:append-empty-element('driver-CodeDomain', .)" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="driver-CodeDomain/CodeList" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="language" as="xs:string" tunnel="yes"/>
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="eno:append-empty-element('driver-CodeDomain', .)" tunnel="yes"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="eno:child-fields($source-context)" mode="source">
			<xsl:with-param name="driver" select="eno:append-empty-element('driver-Mapping', .)" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="driver-CodeDomain/Code" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="language" as="xs:string" tunnel="yes"/>
		<Dimension dimensionType="MEASURE" dynamic="0">
			<Label><xsl:value-of select="enopogues:get-label($source-context,$language)"/></Label>
		</Dimension>
	</xsl:template>

	<xsl:template match="driver-Mapping/Code" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<Mapping>
			<MappingSource>---no-source-found!---</MappingSource>
			<MappingTarget><xsl:value-of select="replace(substring-after(enopogues:get-name($source-context),'fakeCL-'),'-',' ')"/></MappingTarget>
		</Mapping>
	</xsl:template>

	<xsl:template match="TextDomain | DateTimeDomain | NumericDomain" mode="model">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<!--<xsl:param name="id-question" as="xs:string" tunnel="yes"/>-->
		<xsl:variable name="id" select="substring-after(enopogues:get-name($source-context), 'QOP-')"/>
		<xsl:variable name="lenghtResponse" select="enopogues:get-length($source-context)"/>
		<xsl:variable name="typeName">
			<xsl:choose>
				<xsl:when test="self::TextDomain">TEXT</xsl:when>
				<xsl:when test="self::DateTimeDomain">DATE</xsl:when>
				<xsl:when test="self::NumericDomain">NUMERIC</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="typeData">
			<xsl:choose>
				<xsl:when test="self::TextDomain">TextDatatypeType</xsl:when>
				<xsl:when test="self::DateTimeDomain">DateDatatypeType</xsl:when>
				<xsl:when test="self::NumericDomain">NumericDatatypeType</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<Response id="{$id}">
			<xsl:attribute name="mandatory" select="enopogues:is-required($source-context)"/>
			<Datatype typeName="{$typeName}" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="{$typeData}">
			<xsl:if test="$lenghtResponse != '' and (self::TextDomain or self::TextareaDomain)">
				<MaxLength><xsl:value-of select="enopogues:get-length($source-context)"/></MaxLength>
			</xsl:if>
			<xsl:if test="self::TextDomain">
				<Pattern>---- TODO -----</Pattern>
			</xsl:if>
			<xsl:if test="self::NumericDomain">
				<xsl:variable name="minimumResponse" select="enopogues:get-minimum($source-context)"/>
				<xsl:variable name="maximumResponse" select="enopogues:get-maximum($source-context)"/>
				<xsl:variable name="unit" select="'---- TODO -----'"/>
				<xsl:if test="$minimumResponse!=''"><Minimum><xsl:value-of select="$minimumResponse"/></Minimum></xsl:if>
				<xsl:if test="$maximumResponse!=''"><Maximum><xsl:value-of select="$maximumResponse"/></Maximum></xsl:if>
				<xsl:if test="$unit!=''"><Unit><xsl:value-of select="$unit"/></Unit></xsl:if>
			</xsl:if>
			</Datatype>
			<CollectedVariableReference>---- TODO -----</CollectedVariableReference>
		</Response>
	</xsl:template>


	<xsl:template match="driver-Component//Module | driver-Component//SubModule | driver-Component//QuestionItem | driver-Component//QuestionGrid">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<MemberReference><xsl:value-of select="enopogues:get-name($source-context)"/></MemberReference>
	</xsl:template>

	<xsl:template match="driver-VariableScheme//CollectedVariable">
		<xsl:param name="source-context" as="item()" tunnel="yes"/>
		<xsl:param name="language" as="xs:string" tunnel="yes"/>
		<xsl:variable name="id" select="enopogues:get-variable-id($source-context)"/>
		<Variable id="${id}" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CollectedVariableType">
			<Datatype typeName="TODO!" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="TODO!">
				<MaxLength>---- TODO -----</MaxLength>
				<Pattern>
				</Pattern>
			</Datatype>
			<Name><xsl:value-of select="enopogues:get-name($source-context)"/></Name>
			<Label><xsl:value-of select="enopogues:get-label($source-context,$language)"/></Label>
		</Variable>
	</xsl:template>

</xsl:stylesheet>