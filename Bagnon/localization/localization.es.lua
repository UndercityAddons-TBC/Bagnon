--[[
	Bagnon Localization file: Spanish
		Credit goes to Ferroginus
--]]

local L = LibStub('AceLocale-3.0'):NewLocale('Bagnon', 'esES')
if not L then return end

--bindings
L.BagnonToggle = "Activar Inventario"
L.BanknonToggle = "Activar Banco"

--system messages
L.NewUser = "Nuevo usuario detectado, cargando opciones por defecto"
L.Updated = "Opciones de Bagnon actualizadas a v%s"
L.UpdatedIncompatible = "Actualizando desde una versión incompatible, cargando opciones por defecto"

--errors
L.ErrorNoSavedBank = "No se puede abrir el banco, no hay datos disponibles"

--slash commands
L.Commands = "Comandos:"
L.ShowMenuDesc = "Muestra el Menú"
L.ShowBagsDesc = "Activa el inventario"
L.ShowBankDesc = "Activa el banco"

--frame text
L.TitleBank = "Banco de %s"
L.TitleBags = "Inventario de %s"
L.ShowBags = "Mostrar Bolsas"
L.HideBags = "Ocultar Bolsas"

--tooltips
L.TipShowMenu = "<Botón DER> para menú de opciones"
L.TipShowSearch = "<Doble-Click> para buscar"
L.TipShowBag = "<Botón IZQ> para mostrar"
L.TipHideBag = "<Botón IZQ> para esconder"
L.TipGoldOnRealm = "Total on %s"