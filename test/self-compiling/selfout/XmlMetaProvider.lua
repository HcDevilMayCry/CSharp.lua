-- Generated by CSharp.lua Compiler
--[[
Copyright 2017 YANG Huan (sy.yanghuan@gmail.com).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]
local System = System
local MicrosoftCodeAnalysis = Microsoft.CodeAnalysis
local SystemIO = System.IO
local SystemText = System.Text
local SystemXmlSerialization = System.Xml.Serialization
local CSharpLua
local CSharpLuaXmlMetaProvider
local CSharpLuaXmlMetaProviderXmlMetaModel
System.usingDeclare(function (global)
  CSharpLua = global.CSharpLua
  CSharpLuaXmlMetaProvider = CSharpLua.XmlMetaProvider
  CSharpLuaXmlMetaProviderXmlMetaModel = CSharpLua.XmlMetaProvider.XmlMetaModel
end)
System.namespace("CSharpLua", function (namespace)
  namespace.class("XmlMetaProvider", function (namespace)
    namespace.class("XmlMetaModel", function (namespace)
      namespace.class("TemplateModel", function (namespace)
        return {}
      end)
      namespace.class("PropertyModel", function (namespace)
        local getCheckIsField
        getCheckIsField = function (this)
          if this.IsField ~= nil then
            if this.IsField:Equals(System.Boolean.TrueString, 5 --[[StringComparison.OrdinalIgnoreCase]]) then
              return true
            end
            if this.IsField:Equals(System.Boolean.FalseString, 5 --[[StringComparison.OrdinalIgnoreCase]]) then
              return false
            end
          end
          return nil
        end
        return {
          Baned = false,
          getCheckIsField = getCheckIsField
        }
      end)
      namespace.class("FieldModel", function (namespace)
        return {
          Baned = false
        }
      end)
      namespace.class("ArgumentModel", function (namespace)
        return {}
      end)
      namespace.class("MethodModel", function (namespace)
        local __ctor__
        __ctor__ = function (this)
          this.ArgCount = - 1
          this.GenericArgCount = - 1
        end
        return {
          IgnoreGeneric = false,
          Baned = false,
          __ctor__ = __ctor__
        }
      end)
      namespace.class("ClassModel", function (namespace)
        return {
          Baned = false
        }
      end)
      namespace.class("NamespaceModel", function (namespace)
        return {
          Baned = false
        }
      end)
      namespace.class("AssemblyModel", function (namespace)
        return {}
      end)
      namespace.class("ExportModel", function (namespace)
        namespace.class("AttributeModel", function (namespace)
          return {}
        end)
        return {}
      end)
      return {}
    end)
    namespace.class("MethodMetaInfo", function (namespace)
      local Add, CheckIsSingleModel, GetTypeString, IsTypeMatch, IsArgMatch, IsMethodMatch, GetName, GetCodeTemplate, 
      GetIgnoreGeneric, GetMetaInfo, __ctor__
      __ctor__ = function (this)
        this.models_ = System.List(CSharpLuaXmlMetaProviderXmlMetaModel.MethodModel)()
      end
      Add = function (this, model)
        this.models_:Add(model)
        CheckIsSingleModel(this)
      end
      CheckIsSingleModel = function (this)
        local isSingle = false
        if #this.models_ == 1 then
          local model = CSharpLua.Utility.First(this.models_, CSharpLuaXmlMetaProviderXmlMetaModel.MethodModel)
          if model.ArgCount == - 1 and model.Args == nil and model.RetType == nil and model.GenericArgCount == - 1 then
            isSingle = true
          end
        end
        this.isSingleModel_ = isSingle
      end
      GetTypeString = function (symbol)
        if symbol:getKind() == 17 --[[SymbolKind.TypeParameter]] then
          return symbol:getName()
        end

        local sb = SystemText.StringBuilder()
        local typeSymbol = System.cast(MicrosoftCodeAnalysis.INamedTypeSymbol, symbol:getOriginalDefinition())
        local namespaceSymbol = typeSymbol:getContainingNamespace()

        if symbol:getContainingType() ~= nil then
          sb:Append(GetTypeString(symbol:getContainingType()))
          sb:AppendChar(46 --[['.']])
        elseif not namespaceSymbol:getIsGlobalNamespace() then
          sb:Append(namespaceSymbol:ToString())
          sb:AppendChar(46 --[['.']])
        end
        sb:Append(symbol:getName())
        if typeSymbol:getTypeArguments():getLength() > 0 then
          sb:AppendChar(94 --[['^']])
          sb:Append(typeSymbol:getTypeArguments():getLength())
        end
        return sb:ToString()
      end
      IsTypeMatch = function (symbol, typeString)
        if symbol:getKind() == 1 --[[SymbolKind.ArrayType]] then
          local typeSymbol = System.cast(MicrosoftCodeAnalysis.IArrayTypeSymbol, symbol)
          local elementTypeName = GetTypeString(typeSymbol:getElementType())
          return elementTypeName .. "[]" == typeString
        else
          local name = GetTypeString(symbol)
          return name == typeString
        end
      end
      IsArgMatch = function (symbol, parameterModel)
        if not IsTypeMatch(symbol, parameterModel.type) then
          return false
        end

        if parameterModel.GenericArgs ~= nil then
          local typeSymbol = System.cast(MicrosoftCodeAnalysis.INamedTypeSymbol, symbol)
          if typeSymbol:getTypeArguments():getLength() ~= #parameterModel.GenericArgs then
            return false
          end

          local index = 0
          for _, typeArgument in System.each(typeSymbol:getTypeArguments()) do
            local genericArgModel = parameterModel.GenericArgs:get(index)
            if not IsArgMatch(typeArgument, genericArgModel) then
              return false
            end
            index = index + 1
          end
        end

        return true
      end
      IsMethodMatch = function (this, model, symbol)
        if model.name ~= symbol:getName() then
          return false
        end

        if model.ArgCount ~= - 1 then
          if symbol:getParameters():getLength() ~= model.ArgCount then
            return false
          end
        end

        if model.GenericArgCount ~= - 1 then
          if symbol:getTypeArguments():getLength() ~= model.GenericArgCount then
            return false
          end
        end

        if not System.String.IsNullOrEmpty(model.RetType) then
          if not IsTypeMatch(symbol:getReturnType(), model.RetType) then
            return false
          end
        end

        if model.Args ~= nil then
          if symbol:getParameters():getLength() ~= #model.Args then
            return false
          end

          local index = 0
          for _, parameter in System.each(symbol:getParameters()) do
            local parameterModel = model.Args:get(index)
            if not IsArgMatch(parameter:getType(), parameterModel) then
              return false
            end
            index = index + 1
          end
        end

        return true
      end
      GetName = function (this, symbol)
        local methodModel
        if this.isSingleModel_ then
          methodModel = CSharpLua.Utility.First(this.models_, CSharpLuaXmlMetaProviderXmlMetaModel.MethodModel)
        else
          methodModel = this.models_:Find(function (i)
            return IsMethodMatch(this, i, symbol)
          end)
        end
        if methodModel ~= nil and methodModel.Baned then
          System.throw(CSharpLua.CompilationErrorException:new(1, ("{0} is baned"):Format(symbol)))
        end
        local default = methodModel
        if default ~= nil then
          default = default.Name
        end
        return default
      end
      GetCodeTemplate = function (this, symbol)
        if this.isSingleModel_ then
          return CSharpLua.Utility.First(this.models_, CSharpLuaXmlMetaProviderXmlMetaModel.MethodModel).Template
        end

        local methodModel = this.models_:Find(function (i)
          return IsMethodMatch(this, i, symbol)
        end)
        if methodModel ~= nil and methodModel.Baned then
          System.throw(CSharpLua.CompilationErrorException:new(1, ("{0} is baned"):Format(symbol)))
        end
        local default = methodModel
        if default ~= nil then
          default = default.Template
        end
        return default
      end
      GetIgnoreGeneric = function (this, symbol)
        local isIgnoreGeneric = false
        local methodModel
        if this.isSingleModel_ then
          methodModel = CSharpLua.Utility.First(this.models_, CSharpLuaXmlMetaProviderXmlMetaModel.MethodModel)
          isIgnoreGeneric = methodModel.IgnoreGeneric
        else
          methodModel = this.models_:Find(function (i)
            return IsMethodMatch(this, i, symbol)
          end)
          if methodModel ~= nil then
            isIgnoreGeneric = methodModel.IgnoreGeneric
          end
        end
        if methodModel ~= nil and methodModel.Baned then
          System.throw(CSharpLua.CompilationErrorException:new(1, ("{0} is baned"):Format(symbol)))
        end
        return isIgnoreGeneric and System.Boolean.TrueString or System.Boolean.FalseString
      end
      GetMetaInfo = function (this, symbol, type)
        repeat
          local default = type
          if default == 0 --[[MethodMetaType.Name]] then
            do
              return GetName(this, symbol)
            end
          elseif default == 1 --[[MethodMetaType.CodeTemplate]] then
            do
              return GetCodeTemplate(this, symbol)
            end
          elseif default == 2 --[[MethodMetaType.IgnoreGeneric]] then
            do
              return GetIgnoreGeneric(this, symbol)
            end
          else
            do
              System.throw(CSharpLua.InvalidOperationException())
            end
          end
        until 1
      end
      return {
        isSingleModel_ = false,
        Add = Add,
        GetMetaInfo = GetMetaInfo,
        __ctor__ = __ctor__
      }
    end)
    namespace.class("TypeMetaInfo", function (namespace)
      local getModel, Field, Property, Method, GetFieldModel, GetPropertyModel, GetMethodMetaInfo, __init__, 
      __ctor__
      __init__ = function (this)
        this.fields_ = System.Dictionary(System.String, CSharpLuaXmlMetaProviderXmlMetaModel.FieldModel)()
        this.propertys_ = System.Dictionary(System.String, CSharpLuaXmlMetaProviderXmlMetaModel.PropertyModel)()
        this.methods_ = System.Dictionary(System.String, CSharpLuaXmlMetaProvider.MethodMetaInfo)()
      end
      __ctor__ = function (this, model)
        __init__(this)
        this.model_ = model
        Field(this)
        Property(this)
        Method(this)
      end
      getModel = function (this)
        return this.model_
      end
      Field = function (this)
        if this.model_.Fields ~= nil then
          for _, fieldModel in System.each(this.model_.Fields) do
            if System.String.IsNullOrEmpty(fieldModel.name) then
              System.throw(System.ArgumentException(("type [{0}] has a field name is empty"):Format(this.model_.name)))
            end

            if this.fields_:ContainsKey(fieldModel.name) then
              System.throw(System.ArgumentException(("type [{0}]'s field [{1}] is already exists"):Format(this.model_.name, fieldModel.name)))
            end
            this.fields_:Add(fieldModel.name, fieldModel)
          end
        end
      end
      Property = function (this)
        if this.model_.Propertys ~= nil then
          for _, propertyModel in System.each(this.model_.Propertys) do
            if System.String.IsNullOrEmpty(propertyModel.name) then
              System.throw(System.ArgumentException(("type [{0}] has a property name is empty"):Format(this.model_.name)))
            end

            if this.fields_:ContainsKey(propertyModel.name) then
              System.throw(System.ArgumentException(("type [{0}]'s property [{1}] is already exists"):Format(this.model_.name, propertyModel.name)))
            end
            this.propertys_:Add(propertyModel.name, propertyModel)
          end
        end
      end
      Method = function (this)
        if this.model_.Methods ~= nil then
          for _, methodModel in System.each(this.model_.Methods) do
            if System.String.IsNullOrEmpty(methodModel.name) then
              System.throw(System.ArgumentException(("type [{0}] has a method name is empty"):Format(this.model_.name)))
            end

            local info = CSharpLua.Utility.GetOrDefault1(this.methods_, methodModel.name, nil, System.String, CSharpLuaXmlMetaProvider.MethodMetaInfo)
            if info == nil then
              info = CSharpLuaXmlMetaProvider.MethodMetaInfo()
              this.methods_:Add(methodModel.name, info)
            end
            info:Add(methodModel)
          end
        end
      end
      GetFieldModel = function (this, name)
        return CSharpLua.Utility.GetOrDefault1(this.fields_, name, nil, System.String, CSharpLuaXmlMetaProviderXmlMetaModel.FieldModel)
      end
      GetPropertyModel = function (this, name)
        return CSharpLua.Utility.GetOrDefault1(this.propertys_, name, nil, System.String, CSharpLuaXmlMetaProviderXmlMetaModel.PropertyModel)
      end
      GetMethodMetaInfo = function (this, name)
        return CSharpLua.Utility.GetOrDefault1(this.methods_, name, nil, System.String, CSharpLuaXmlMetaProvider.MethodMetaInfo)
      end
      return {
        getModel = getModel,
        GetFieldModel = GetFieldModel,
        GetPropertyModel = GetPropertyModel,
        GetMethodMetaInfo = GetMethodMetaInfo,
        __ctor__ = __ctor__
      }
    end)
    local LoadNamespace, LoadType, GetNamespaceMapName, MayHaveCodeMeta, GetTypeShortString, GetTypeMapName, GetTypeMetaInfo, IsPropertyField, 
    GetFieldCodeTemplate, GetProertyCodeTemplate, GetInternalMethodMetaInfo, GetMethodMetaInfo, GetMethodMapName, GetMethodCodeTemplate, IsMethodIgnoreGeneric, IsExportAttribute, 
    class, __init__, __ctor__
    __init__ = function (this)
      this.namespaceNameMaps_ = System.Dictionary(System.String, CSharpLuaXmlMetaProviderXmlMetaModel.NamespaceModel)()
      this.typeMetas_ = System.Dictionary(System.String, class.TypeMetaInfo)()
      this.exportAttributes_ = System.HashSet(System.String)()
    end
    __ctor__ = function (this, files)
      __init__(this)
      for _, file in System.each(files) do
        local xmlSeliz = SystemXmlSerialization.XmlSerializer(System.typeof(class.XmlMetaModel))
        System.try(function ()
          System.using(SystemIO.FileStream(file, 3 --[[FileMode.Open]], 1 --[[FileAccess.Read]], 1 --[[FileShare.Read]]), function (stream)
            local model = System.cast(class.XmlMetaModel, xmlSeliz:Deserialize(stream))
            local assembly = model.Assembly
            if assembly ~= nil then
              if assembly.Namespaces ~= nil then
                for _, namespaceModel in System.each(assembly.Namespaces) do
                  LoadNamespace(this, namespaceModel)
                end
              end
              if assembly.Classes ~= nil then
                LoadType(this, "", assembly.Classes)
              end
            end
            local export = model.Export
            if export ~= nil then
              if export.Attributes ~= nil then
                for _, attribute in System.each(export.Attributes) do
                  if System.String.IsNullOrEmpty(attribute.Name) then
                    System.throw(System.ArgumentException("attribute's name is empty"))
                  end
                  this.exportAttributes_:Add(attribute.Name)
                end
              end
            end
          end)
        end, function (default)
          local e = default
          System.throw(System.Exception(("load xml file wrong at {0}"):Format(file), e))
        end)
      end
    end
    LoadNamespace = function (this, model)
      local namespaceName = model.name
      if namespaceName == nil then
        System.throw(System.ArgumentException("namespace's name is null"))
      end

      if #namespaceName > 0 and not System.String.IsNullOrEmpty(model.Name) then
        if this.namespaceNameMaps_:ContainsKey(namespaceName) then
          System.throw(System.ArgumentException(("namespace [{0}] is already has"):Format(namespaceName)))
        end
        this.namespaceNameMaps_:Add(namespaceName, model)
      end

      if model.Classes ~= nil then
        local default
        if not System.String.IsNullOrEmpty(model.Name) then
          default = model.Name
        else
          default = namespaceName
        end
        local name = default
        LoadType(this, name, model.Classes)
      end
    end
    LoadType = function (this, namespaceName, classes)
      for _, classModel in System.each(classes) do
        local className = classModel.name
        if System.String.IsNullOrEmpty(className) then
          System.throw(System.ArgumentException(("namespace [{0}] has a class's name is empty"):Format(namespaceName)))
        end

        local default
        if #namespaceName > 0 then
          default = (namespaceName .. '.') .. className
        else
          default = className
        end
        local classesfullName = default
        classesfullName = classesfullName:Replace(94 --[['^']], 95 --[['_']])
        if this.typeMetas_:ContainsKey(classesfullName) then
          System.throw(System.ArgumentException(("type [{0}] is already has"):Format(classesfullName)))
        end
        local info = class.TypeMetaInfo(classModel)
        this.typeMetas_:Add(classesfullName, info)
      end
    end
    GetNamespaceMapName = function (this, symbol, original)
      local info = CSharpLua.Utility.GetOrDefault1(this.namespaceNameMaps_, original, nil, System.String, CSharpLuaXmlMetaProviderXmlMetaModel.NamespaceModel)
      if info ~= nil then
        if info.Baned then
          System.throw(CSharpLua.CompilationErrorException:new(1, ("{0} is baned"):Format(symbol)))
        end
        return info.Name
      end
      return nil
    end
    MayHaveCodeMeta = function (this, symbol)
      return symbol:getDeclaredAccessibility() == 6 --[[Accessibility.Public]] and not CSharpLua.Utility.IsFromCode(symbol)
    end
    GetTypeShortString = function (this, symbol)
      local typeSymbol = System.cast(MicrosoftCodeAnalysis.INamedTypeSymbol, symbol:getOriginalDefinition())
      return CSharpLua.Utility.GetTypeShortName(typeSymbol, System.bind(this, GetNamespaceMapName))
    end
    GetTypeMapName = function (this, symbol, shortName)
      if MayHaveCodeMeta(this, symbol) then
        local info = CSharpLua.Utility.GetOrDefault1(this.typeMetas_, shortName, nil, System.String, class.TypeMetaInfo)
        if info ~= nil and info:getModel().Baned then
          System.throw(CSharpLua.CompilationErrorException:new(1, ("{0} is baned"):Format(symbol)))
        end
        local default = info
        if default ~= nil then
          default = default.getModel().Name
        end
        return default
      end
      return nil
    end
    GetTypeMetaInfo = function (this, memberSymbol)
      local typeName = GetTypeShortString(this, memberSymbol:getContainingType())
      local info = CSharpLua.Utility.GetOrDefault1(this.typeMetas_, typeName, nil, System.String, class.TypeMetaInfo)
      if info ~= nil and info:getModel().Baned then
        System.throw(CSharpLua.CompilationErrorException:new(1, ("{0} is baned"):Format(memberSymbol:getContainingType())))
      end
      return info
    end
    IsPropertyField = function (this, symbol)
      if MayHaveCodeMeta(this, symbol) then
        local default = GetTypeMetaInfo(this, symbol)
        if default ~= nil then
          default = default:GetPropertyModel(symbol:getName())
        end
        local info = default
        local extern = info
        if extern ~= nil then
          extern = extern.getCheckIsField()
        end
        return extern
      end
      return nil
    end
    GetFieldCodeTemplate = function (this, symbol)
      if MayHaveCodeMeta(this, symbol) then
        local default = GetTypeMetaInfo(this, symbol)
        if default ~= nil then
          default = default:GetFieldModel(symbol:getName())
        end
        local info = default
        if info ~= nil and info.Baned then
          System.throw(CSharpLua.CompilationErrorException:new(1, ("{0} is baned"):Format(symbol)))
        end
        local extern = info
        if extern ~= nil then
          extern = extern.Template
        end
        return extern
      end
      return nil
    end
    GetProertyCodeTemplate = function (this, symbol, isGet)
      if MayHaveCodeMeta(this, symbol) then
        local default = GetTypeMetaInfo(this, symbol)
        if default ~= nil then
          default = default:GetPropertyModel(symbol:getName())
        end
        local info = default
        if info ~= nil then
          if info.Baned then
            System.throw(CSharpLua.CompilationErrorException:new(1, ("{0} is baned"):Format(symbol)))
          end
          local extern
          if isGet then
            local ref = info.get
            if ref ~= nil then
              ref = ref.Template
            end
            extern = ref
          else
            local out = info.set
            if out ~= nil then
              out = out.Template
            end
            extern = out
          end
          return extern
        end
      end
      return nil
    end
    GetInternalMethodMetaInfo = function (this, symbol, metaType)
      assert(symbol ~= nil)
      if symbol:getDeclaredAccessibility() ~= 6 --[[Accessibility.Public]] then
        return nil
      end

      local codeTemplate = nil
      if not CSharpLua.Utility.IsFromCode(symbol) then
        local default = GetTypeMetaInfo(this, symbol)
        if default ~= nil then
          default = default:GetMethodMetaInfo(symbol:getName())
          if default ~= nil then
            default = default:GetMetaInfo(symbol, metaType)
          end
        end
        codeTemplate = default
      end

      if codeTemplate == nil then
        if symbol:getIsOverride() then
          if symbol:getOverriddenMethod() ~= nil then
            codeTemplate = GetInternalMethodMetaInfo(this, symbol:getOverriddenMethod(), metaType)
          end
        else
          local interfaceImplementations = CSharpLua.Utility.InterfaceImplementations(symbol, MicrosoftCodeAnalysis.IMethodSymbol)
          if interfaceImplementations ~= nil then
            for _, interfaceMethod in System.each(interfaceImplementations) do
              codeTemplate = GetInternalMethodMetaInfo(this, interfaceMethod, metaType)
              if codeTemplate ~= nil then
                break
              end
            end
          end
        end
      end
      return codeTemplate
    end
    GetMethodMetaInfo = function (this, symbol, metaType)
      symbol = CSharpLua.Utility.CheckMethodDefinition(symbol)
      return GetInternalMethodMetaInfo(this, symbol, metaType)
    end
    GetMethodMapName = function (this, symbol)
      return GetMethodMetaInfo(this, symbol, 0 --[[MethodMetaType.Name]])
    end
    GetMethodCodeTemplate = function (this, symbol)
      return GetMethodMetaInfo(this, symbol, 1 --[[MethodMetaType.CodeTemplate]])
    end
    IsMethodIgnoreGeneric = function (this, symbol)
      return GetMethodMetaInfo(this, symbol, 2 --[[MethodMetaType.IgnoreGeneric]]) == System.Boolean.TrueString
    end
    IsExportAttribute = function (this, attributeTypeSymbol)
      return this.exportAttributes_:getCount() > 0 and this.exportAttributes_:Contains(attributeTypeSymbol:ToString())
    end
    class = {
      GetNamespaceMapName = GetNamespaceMapName,
      MayHaveCodeMeta = MayHaveCodeMeta,
      GetTypeMapName = GetTypeMapName,
      IsPropertyField = IsPropertyField,
      GetFieldCodeTemplate = GetFieldCodeTemplate,
      GetProertyCodeTemplate = GetProertyCodeTemplate,
      GetMethodMapName = GetMethodMapName,
      GetMethodCodeTemplate = GetMethodCodeTemplate,
      IsMethodIgnoreGeneric = IsMethodIgnoreGeneric,
      IsExportAttribute = IsExportAttribute,
      __ctor__ = __ctor__
    }
    return class
  end)
end)
