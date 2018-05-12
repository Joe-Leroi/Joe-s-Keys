
--- Vous pouvez modifier seulement cela ---

LangueS = "fr" --- Auncune autre langue n'est disponible pour le moment ---
devvoiture = "Vous avez déverrouillé votre véhicule."
devporte = "Vous avez déverrouillé votre porte."
verporte = "Vous avez fermé votre porte clé."
vervoiture = "Vous avez verrouillé votre véhicule."


--- NE PAS TOUCHER, SINON LE SCRIPTS NE FONCTIONNERA PAS ! ---
Auteur = "Joe Leroi & enzoFR60"


--- NE PAS TOUCHER, SINON LE SCRIPTS RISQUE DE CREE DES ERREURS ! --
local VersionJ = "1.0.1"

hook.Add( "PlayerConnect", "JoeKeysCheckV", function()
	http.Fetch( "https://raw.githubusercontent.com/Joe-Leroi/Joe-s-Keys/master/Version", function( body, len, headers, code )
		local body = string.gsub( body, "\n", "" )
		if ( body == VersionJ ) then
			print( "[Joe's Keys] Vous utilisez la version la plus récente de cette addons!" )
		elseif ( body == "404: Not Found") then
			print( "[Joe's Keys] La page de la version n'existe pas!")
		else
			print( "[Joe's Keys] Vous utilisez une version obsolète de Joe's Keys! (Dernière: " .. body .. ", Actuelle: " .. Version .. ")" )
		end
	end,
	function( error )
		print( "[Joe's Keys] Impossible de récupérer la version du scripts! (" .. error .. ")" )
	end )

	hook.Remove( "PlayerConnect", "JoeKeysCheckV" )
end )
