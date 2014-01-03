<?xml version="1.0"	standalone="no"?>
<!--
   : $Id: mindmanager2mm.xsl,v 1.3 2010-03-27 00:56:34 ericblue76 Exp $
   : Convert from MindManager (c) to FreeMind (	;) ).
   :
   : This code released	under the GPL.
   : (http://www.gnu.org/copyleft/gpl.html)	
   :
   : Christian Foltin, June, 2005
   :
   : Modified version for MindMap Viewer (http://eric-blue.com/projects/mindmapviewer)
   :
   :
  -->
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ap="http://schemas.mindjet.com/MindManager/Application/2003" xmlns:cor="http://schemas.mindjet.com/MindManager/Core/2003" xmlns:pri="http://schemas.mindjet.com/MindManager/Primitive/2003" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">	
	<xsl:strip-space elements="*"/>	
	<xsl:output	method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:template match="/ap:Map">
		<map version="0.8.0">
			<xsl:apply-templates select="ap:OneTopic/ap:Topic"/>
		</map>
	</xsl:template>	
	<xsl:template match="ap:Topic">	
		<node>
			<!-- Change	position logic since Flash viewer has difficulty displaying	values that	default	to Left	-->	
			<xsl:choose>
				<xsl:when test="./ap:Offset/@CX">
					<xsl:attribute name="POSITION">	
						<xsl:choose>
							<xsl:when test="ap:Offset/@CX &gt; 0">
								<xsl:text>right</xsl:text>
							</xsl:when>	
							<xsl:when test="ap:Offset/@CX &lt; 0">
								<xsl:text>left</xsl:text>
							</xsl:when>	
							<xsl:when test="ap:Offset/@CX =	0">	
								<xsl:text/>	
							</xsl:when>	
						</xsl:choose>
					</xsl:attribute>
				</xsl:when>	
			</xsl:choose>
			
			<xsl:choose>
				<xsl:when test="./ap:Hyperlink">
					<xsl:attribute name="LINK"><xsl:value-of select="./ap:Hyperlink/@Url"/></xsl:attribute>	
				</xsl:when>	
				<xsl:when test="./ap:Text/ap:Font/@Color">
					<xsl:attribute name="COLOR">
						<xsl:text>#</xsl:text><xsl:value-of	
							select="substring(./ap:Text/ap:Font/@Color,3)"/>
					</xsl:attribute>
				</xsl:when>	
				<xsl:when test="./ap:SubTopicShape/@SubTopicShape='urn:mindjet:Oval'">
					<xsl:attribute name="STYLE"><xsl:text>bubble</xsl:text></xsl:attribute>	
				</xsl:when>	
			</xsl:choose>
			
			<xsl:choose>
				<xsl:when
					test="./ap:OneImage/ap:Image/ap:ImageData/@ImageType='urn:mindjet:MetafileImage'">
					
					<xsl:attribute name="TEXT">{<xsl:value-of
						select="./ap:OneImage/ap:Image/ap:ImageData/cor:Uri"/>,<xsl:value-of
						select="substring-before(./ap:OneImage/ap:Image/ap:ImageSize/@Height,'.')"/>,<xsl:value-of
						select="substring-before(./ap:OneImage/ap:Image/ap:ImageSize/@Width,'.')"/>}<xsl:value-of 
						select="./ap:Text/@PlainText"/>	
					</xsl:attribute>
				</xsl:when>	
				<xsl:otherwise>	
					<xsl:attribute name="TEXT">	
						<xsl:value-of select="./ap:Text/@PlainText"/>
					</xsl:attribute>
					
				</xsl:otherwise>
			</xsl:choose>

			<xsl:variable name="gpNode"	select="name(../..)"/>	
		
			<xsl:choose>
				<xsl:when test="$gpNode='ap:Map'">
					<!-- Don't do anything with	root node for now -->
				</xsl:when>	
				<xsl:otherwise>	
					<xsl:choose>
						<xsl:when test="./ap:Color">
							<cloud>	
								<xsl:attribute name="COLOR">#<xsl:value-of select="substring(./ap:Color/@FillColor,3,8)"/></xsl:attribute>
							</cloud>
						</xsl:when>	
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
						
			<xsl:apply-templates select="./ap:NotesGroup"/>	
			<xsl:apply-templates select="./ap:SubTopics/ap:Topic"/>	
			<xsl:apply-templates select="./ap:IconsGroup"/>	
		</node>	
	</xsl:template>	
	<xsl:template match="ap:NotesGroup">
		<xsl:element name="hook">
			<xsl:attribute name="NAME"><xsl:text>accessories/plugins/NodeNote.properties</xsl:text></xsl:attribute>	
			<xsl:element name="text">
				<xsl:value-of select="ap:NotesXhtmlData/@PreviewPlainText"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>	
	<xsl:template match="ap:IconsGroup">
		<xsl:apply-templates select="./ap:Icons"/>
	</xsl:template>	
	<xsl:template match="ap:Icons">	
		<xsl:apply-templates select="./ap:Icon"/>
	</xsl:template>	
	<xsl:template match="ap:Icon[@xsi:type='ap:StockIcon']">
		<xsl:element name="icon">
			<xsl:attribute name="BUILTIN">
				<xsl:choose>
					<xsl:when test="@IconType='urn:mindjet:SmileyAngry'">clanbomber</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:SmileyNeutral'">button_ok</xsl:when>	
					<xsl:when test="@IconType='urn:mindjet:SmileySad'">clanbomber</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:SmileyHappy'">ksmiletris</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:SmileyScreaming'">ksmiletris</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:ArrowRight'">forward</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:ArrowLeft'">back</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:FlagGreen'">flag</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:FlagYellow'">flag</xsl:when>	
					<xsl:when test="@IconType='urn:mindjet:FlagPurple'">flag</xsl:when>	
					<xsl:when test="@IconType='urn:mindjet:FlagBlack'">flag</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:FlagBlue'">flag</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:FlagOrange'">flag</xsl:when>	
					<xsl:when test="@IconType='urn:mindjet:FlagRed'">flag</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:ThumbsUp'">button_ok</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:Calendar'">bell</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:Emergency'">messagebox_warning</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:OnHold'">knotify</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:Stop'">button_cancel</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:Prio1'">full-1</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:Prio2'">full-2</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:Prio3'">full-3</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:Prio4'">full-4</xsl:when>
					<xsl:when test="@IconType='urn:mindjet:Prio5'">full-5</xsl:when>
					<xsl:otherwise>	
						<xsl:text>messagebox_warning</xsl:text>	
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>	
	<xsl:template match="node()|@*"/>
</xsl:stylesheet>
