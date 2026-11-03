<#-- @formatter:off -->
{
  "models": {
    <#assign first = true>
    <#list w.getElementsOfType("item") as element>
      <#assign item = element.getGeneratableElement()>
      <#if item?? && item.renderType == 2 && item.customModelName?has_content>
        <#if first == false>,</#if>
        <#assign first = false>
        "${element.getRegistryName()}": {
          "obj": "${item.customModelName?split(":")[0]}",
          "model": "item/${element.getRegistryName()}",
          "display": "item"
        }
      </#if>
    </#list>
    <#list w.getElementsOfType("tool") as element>
      <#assign tool = element.getGeneratableElement()>
      <#if tool?? && tool.renderType == 2 && tool.customModelName?has_content>
        <#if first == false>,</#if>
        <#assign first = false>
        "${element.getRegistryName()}": {
          "obj": "${tool.customModelName?split(":")[0]}",
          "model": "item/${element.getRegistryName()}",
          "display": "tool"
        }
      </#if>
    </#list>
    <#list w.getElementsOfType("armor") as element>
      <#assign armor = element.getGeneratableElement()>
      <#if armor??>
        <#if armor.enableHelmet && armor.helmetItemRenderType == 2 && armor.helmetItemCustomModelName?has_content>
          <#if first == false>,</#if>
          <#assign first = false>
          "${element.getRegistryName()}_helmet": {
            "obj": "${armor.helmetItemCustomModelName?split(":")[0]}",
            "model": "item/${element.getRegistryName()}_helmet",
            "display": "item"
          }
        </#if>
        <#if armor.enableBody && armor.bodyItemRenderType == 2 && armor.bodyItemCustomModelName?has_content>
          <#if first == false>,</#if>
          <#assign first = false>
          "${element.getRegistryName()}_chestplate": {
            "obj": "${armor.bodyItemCustomModelName?split(":")[0]}",
            "model": "item/${element.getRegistryName()}_chestplate",
            "display": "item"
          }
        </#if>
        <#if armor.enableLeggings && armor.leggingsItemRenderType == 2 && armor.leggingsItemCustomModelName?has_content>
          <#if first == false>,</#if>
          <#assign first = false>
          "${element.getRegistryName()}_leggings": {
            "obj": "${armor.leggingsItemCustomModelName?split(":")[0]}",
            "model": "item/${element.getRegistryName()}_leggings",
            "display": "item"
          }
        </#if>
        <#if armor.enableBoots && armor.bootsItemRenderType == 2 && armor.bootsItemCustomModelName?has_content>
          <#if first == false>,</#if>
          <#assign first = false>
          "${element.getRegistryName()}_boots": {
            "obj": "${armor.bootsItemCustomModelName?split(":")[0]}",
            "model": "item/${element.getRegistryName()}_boots",
            "display": "item"
          }
        </#if>
      </#if>
    </#list>
  }
}
<#-- @formatter:on -->
