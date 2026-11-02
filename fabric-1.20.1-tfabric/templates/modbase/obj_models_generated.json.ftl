<#-- @formatter:off -->
{
  "models": {
    <#assign first = true>
    <#list w.getElementsOfType("block") as element>
      <#assign block = element.getGeneratableElement()>
      <#if block?? && block.renderType() == 3 && block.customModelName?has_content>
        <#if first == false>,</#if>
        <#assign first = false>
        "${element.getRegistryName()}": {
          "obj": "${block.customModelName?split(":")[0]}",
          "texture": "${block.texture.format("%s:block/%s")}",
          "model": "block/${element.getRegistryName()}"
        }
      </#if>
    </#list>
  }
}
<#-- @formatter:on -->
