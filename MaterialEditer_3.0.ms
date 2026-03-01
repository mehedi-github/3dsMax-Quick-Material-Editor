--// ===================================================================================================
--// MATERIAL EDITOR TOOL (Multi-Engine)
--// Version: 3.0 (VRay Support Added)
--// Features: 
--//    - Standard, Physical & VRay Material creation
--//    - Dynamic window resizing (No empty spaces)
--//    - sRGB <-> Linear conversion
--//    - VRay 7+ PBR Workflow (Metalness/Roughness)
--// ===================================================================================================

try(DestroyDialog roMain)catch()
clearListener() 

--// Global Path Variables
global g_MaterialLibPath = "R:\\sp_assets\\libraries\\materials\\"

--// ===================================================================================================
--// ROLLOUT: Standard Material
--// ===================================================================================================
rollout rltSubSM "Standard Material Maker" width:278 height:535 -- Height adjusted to fit content
(
	local resizeCallback 
	
	-- Thumbnails
	local thumb_dif = bitmap 50 50 color:black
	local thumb_nrm = bitmap 50 50 color:black
	local thumb_lit = bitmap 50 50 color:black
	
	local file_dif, file_nrm, file_lit 
	
	--// --- Preset Libraries ---
	local arr_ColorLiblary_List = #(
		"Raw/Naked","White","Black","Dark Gray","Gray","Light Gray",
		"Silver","Charcoal Gray","Beige","Light Beige","Stainless Color",
		"Brown","Dark Brown","Light Brown"
	)
	
	local arr_MaterialLiblary_List = #(
		"Solid Paint (Gloss)","Solid Paint (Matte)","Tile/Stone (Gloss)","Tile/Stone (Matte)",
		"Olefin Sheet","Entrance Door","Vinyl Wallpaper","Ceramic",
		"Aluminum","Chrome Plating","Chrome (Door Knob)","Stainless Steel","Metal (Gloss)","Metal (Matte)",
		"Glass (Clear)","Glass (Translucent)","Glass (Milky)","Frosted Glass","Glass (Side Edge)",
		"Mirror","Frosted Mirror","Bathroom Wall Panel","Resin Panel","Kitchen Panel",
		"Lighting","Unknown","Cross Section"
	)
	
	--// --- UI Controls ---
	checkbutton ckbtn_mtl_get "Pick Object Material" width:135 height:35 across:2 offset:[-5,0] tooltip:"Pick material from selected object"
	button btn_mtl_set "Set Material" width:135 height:35 across:2 offset:[5,0] tooltip:"Apply settings to selection"
	
	edittext etex_mtl_name text:"Material_Name" fieldWidth:145 height:20 readOnly:true offset:[-15,0]
	checkbox ckb_litmap_tgl "Process Lightmap" checked:false width:100 height:20 pos:[173,42]
	
	groupBox grp_mtl_spa "Load [ sp_assets ]" pos:[170,65] width:100 height:50 
	button btn_spa_get "Get Material" offset:[167,-38] width:80 height:25 align:#left
	
	dropdownlist ddl_colLib "Color Library" items:arr_ColorLiblary_List height:10 width:100 align:#left offset:[-10,-40] 
	dropdownlist ddl_matLib "Material Library" items:arr_MaterialLiblary_List height:10 width:150 align:#left offset:[-10,-3] 
	checkbox ckb_onlymtl_tgl "Include Color" checked:false offset:[70,-46] width:80 height:16 align:#left
	
	colorpicker col_pic color:[255,255,255] width:65 height:25 offset:[-14,23] across:4
	spinner spn_R_value "R:" range:[0,255,255] type:#integer fieldwidth: 35 offset:[-6,28] align:#left
	spinner spn_G_value "G:" range:[0,255,255] type:#integer fieldwidth: 35 offset:[-1,28] align:#left
	spinner spn_B_value "B:" range:[0,255,255] type:#integer fieldwidth: 35 offset:[5,28] align:#left
	
	spinner spn_specular_value "Specular:" range:[0,100,20] type:#integer fieldwidth: 35 align:#center offset:[-58,-2]
	spinner spn_opacity_value "Opacity:" range:[0,100,100] type:#integer  fieldwidth: 35 align:#center offset:[-56,-2]
	spinner spn_Glossiness_value "Glossiness:" range:[0,100,50] type:#integer  fieldwidth: 35 align:#center offset:[72,-40]
	spinner spn_selfIllum_value "SelfIllum:" range:[0,100,0] type:#integer  fieldwidth: 35 align:#center offset:[76,-2]

	-- Diffuse Map Group
	groupBox grp_mtl_dif "Diffuse Texture" pos:[0,225] width:277 height:100 align:#left
	bitmap bm_dif_map "Diffuse Map" bitmap:thumb_dif offset:[-8,-90] width:50 height:50 align:#left
	checkbox ckb_dif_tgl "Enable" checked:true offset:[-35,-60] width:85 height:16 align:#center
	spinner spn_dif_amt "Amount:" range:[0,100,100] type:#integer fieldWidth:30 offset:[-14,-4] width:40 height:16 align:#center
	spinner spn_dif_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[50,-40] width:40 height:16 align:#center
	spinner spn_dif_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[50,-3] width:40 height:16 align:#center
	spinner spn_dif_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[50,-2] width:40 height:16 align:#center
	edittext etex_dif_name text:"" fieldWidth:203 height:20 readOnly:true offset:[-12,00] align:#left
	button btn_dif_getmap "Get" width:55 height:30 offset:[7,-75] align:#right
	button btn_dif_removemap "Remove" width:55 height:30 offset:[7,0] align:#right
	
	-- Normal/Bump Map Group
	groupBox grp_mtl_nrm "Bump Texture" pos:[0,325] width:277 height:100 align:#left
	bitmap bm_nrm_map "Bump Map" bitmap:thumb_nrm offset:[-8,-90] width:50 height:50 align:#left
	checkbox ckb_nrm_tgl "Enable" checked:true offset:[-35,-60] width:85 height:16 align:#center
	spinner spn_nrm_amt "Amount:" range:[0,100,100] type:#integer fieldWidth:30 offset:[-14,-4] width:40 height:16 align:#center
	spinner spn_nrm_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[50,-40] width:40 height:16 align:#center
	spinner spn_nrm_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[50,-3] width:40 height:16 align:#center
	spinner spn_nrm_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[50,-2] width:40 height:16 align:#center
	edittext etex_nrm_name text:"" fieldWidth:203 height:20 readOnly:true offset:[-12,00] align:#left
	button btn_nrm_getmap "Get" width:55 height:30 offset:[7,-75] align:#right
	button btn_nrm_removemap "Remove" width:55 height:30 offset:[7,0] align:#right
	
	-- Self-Illumination Map Group
	groupBox grp_mtl_lit "Self Illumination Texture" pos:[0,425] width:277 height:100 align:#left
	bitmap bm_lit_map "Self Illum Map" bitmap:thumb_lit offset:[-8,-90] width:50 height:50 align:#left
	checkbox ckb_lit_tgl "Enable" checked:true offset:[-35,-60] width:85 height:16 align:#center
	spinner spn_lit_amt "Amount:" range:[0,100,100] type:#integer fieldWidth:30 offset:[-14,-4] width:40 height:16 align:#center
	spinner spn_lit_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[50,-40] width:40 height:16 align:#center
	spinner spn_lit_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[50,-3] width:40 height:16 align:#center
	spinner spn_lit_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[50,-2] width:40 height:16 align:#center
	edittext etex_lit_name text:"" fieldWidth:203 height:20 readOnly:true offset:[-12,00] align:#left
	button btn_lit_getmap "Get" width:55 height:30 offset:[7,-75] align:#right
	button btn_lit_removemap "Remove" width:55 height:30 offset:[7,0] align:#right

	--// --- Helper Functions ---
	fn UpdateMapUI mapObj uiBitmap uiText uiCheck uiAmt uiU uiV uiRot &fileVar =
	(
		if mapObj != undefined then (
			local tex = if classof mapObj == Normal_Bump then mapObj.normal_map else mapObj
			if tex != undefined and classof tex == Bitmaptexture then (
				try (
					local tempBmp = openbitmap (tex.filename as string)
					local thumb = bitmap 50 50 
					copy tempBmp thumb
					uiBitmap.bitmap = thumb
					uiText.text = filenameFromPath tex.filename
					fileVar = tex.filename 
				) catch (
					uiBitmap.bitmap = bitmap 50 50 color:red 
					uiText.text = "File Missing"
				)
				uiCheck.checked = true
				uiU.value = tex.coordinates.U_Tiling
				uiV.value = tex.coordinates.V_Tiling
				uiRot.value = tex.coordinates.W_Angle
			)
		) else (
			uiBitmap.bitmap = bitmap 50 50 color:black
			uiText.text = ""
			uiCheck.checked = false
			uiAmt.value = 100
			uiU.value = 1.0; uiV.value = 1.0; uiRot.value = 0.0
			fileVar = undefined
		)
	)

	Fn getMtlParameter trgMtl =
	(
		if ((classof trgMtl) == Standardmaterial) then
		(
			spn_R_value.value = trgMtl.diffuse.R
			spn_G_value.value = trgMtl.diffuse.G
			spn_B_value.value = trgMtl.diffuse.B
			col_pic.color = trgMtl.diffuse
			spn_specular_value.value = trgMtl.specularLevel
			spn_Glossiness_value.value = trgMtl.glossiness
			spn_opacity_value.value = trgMtl.opacity
			spn_selfIllum_value.value = trgMtl.selfIllumAmount
			
			UpdateMapUI trgMtl.diffuseMap bm_dif_map etex_dif_name ckb_dif_tgl spn_dif_amt spn_dif_u_til spn_dif_v_til spn_dif_w_rot &file_dif
			ckb_dif_tgl.checked = trgMtl.diffuseMapEnable
			spn_dif_amt.value = trgMtl.diffuseMapAmount

			UpdateMapUI trgMtl.bumpMap bm_nrm_map etex_nrm_name ckb_nrm_tgl spn_nrm_amt spn_nrm_u_til spn_nrm_v_til spn_nrm_w_rot &file_nrm
			ckb_nrm_tgl.checked = trgMtl.bumpMapEnable
			spn_nrm_amt.value = trgMtl.bumpMapAmount

			UpdateMapUI trgMtl.selfIllumMap bm_lit_map etex_lit_name ckb_lit_tgl spn_lit_amt spn_lit_u_til spn_lit_v_til spn_lit_w_rot &file_lit
			ckb_lit_tgl.checked = trgMtl.selfIllumMapEnable
			spn_lit_amt.value = trgMtl.selfIllumMapAmount
		)
		else( messageBox "Please select an object with Standard Material" )
	)
	
	fn LoadBitmapToUI uiBitmap uiText &fileVar =
	(
		local bmp = selectBitMap()
		if bmp != undefined do (
			local thumb = bitmap 50 50
			copy bmp thumb
			uiBitmap.bitmap = thumb
			uiText.text = filenameFromPath bmp.filename
			fileVar = bmp.filename
		)
	)
	
	fn ClearMapUI uiBitmap uiText &fileVar =
	(
		uiBitmap.bitmap = bitmap 50 50 color:black
		uiText.text = ""
		fileVar = undefined
	)
	
	--// --- Event Handlers ---
	on rltSubSM open do
	(
		bm_dif_map.bitmap = thumb_dif
		bm_nrm_map.bitmap = thumb_nrm
		bm_lit_map.bitmap = thumb_lit
	)
	
	on col_pic changed col do (
		spn_R_value.value = col.r; spn_G_value.value = col.g; spn_B_value.value = col.b
	)
	on spn_R_value changed val do (col_pic.color.r = val)
	on spn_G_value changed val do (col_pic.color.g = val)
	on spn_B_value changed val do (col_pic.color.b = val)
	
	on ckbtn_mtl_get changed state do 
	(
		local obj = pickObject()
		if isValidNode obj and obj.material != undefined do
		(
			etex_mtl_name.text = obj.material.name
			getMtlParameter obj.material
		)
		ckbtn_mtl_get.checked = false
	) 
	
	on btn_mtl_set pressed do 
	(
		undo "Set Standard Material" on 
		(
			for sel in selection where superclassof sel == geometryclass do 
			(
				local targetMat = sel.material
				if targetMat == undefined or classof targetMat != Standardmaterial then (
					local oldName = if targetMat != undefined then targetMat.name else "Standard_Mat"
					targetMat = Standardmaterial name:oldName
					sel.material = targetMat
				)
				
				targetMat.showInViewport = true
				targetMat.diffuse = col_pic.color
				targetMat.specularLevel = spn_specular_value.value
				targetMat.glossiness = spn_Glossiness_value.value
				targetMat.opacity = spn_opacity_value.value
				targetMat.selfIllumAmount = spn_selfIllum_value.value
				
				fn AssignTexture matSlot uiCheck uiAmt uiU uiV uiRot fileName useNormal:false =
				(
					if fileName != undefined and fileName != "" then (
						local map = BitmapTexture filename:fileName
						map.coordinates.U_Tiling = uiU
						map.coordinates.V_Tiling = uiV
						map.coordinates.W_Angle = uiRot
						
						if useNormal then (
							local nrm = Normal_bump()
							nrm.normal_map = map
							return nrm
						) else return map
					)
					return undefined
				)

				targetMat.diffuseMap = AssignTexture targetMat.diffuseMap ckb_dif_tgl.checked spn_dif_amt.value spn_dif_u_til.value spn_dif_v_til.value spn_dif_w_rot.value file_dif
				targetMat.diffuseMapEnable = ckb_dif_tgl.checked
				targetMat.diffuseMapAmount = spn_dif_amt.value
				
				targetMat.bumpMap = AssignTexture targetMat.bumpMap ckb_nrm_tgl.checked spn_nrm_amt.value spn_nrm_u_til.value spn_nrm_v_til.value spn_nrm_w_rot.value file_nrm useNormal:true
				targetMat.bumpMapEnable = ckb_nrm_tgl.checked
				targetMat.bumpMapAmount = spn_nrm_amt.value
				
				if ckb_litmap_tgl.checked do (
					targetMat.selfIllumMap = AssignTexture targetMat.selfIllumMap ckb_lit_tgl.checked spn_lit_amt.value spn_lit_u_til.value spn_lit_v_til.value spn_lit_w_rot.value file_lit
					if targetMat.selfIllumMap != undefined do targetMat.selfIllumMap.coords.mapChannel = 2
					targetMat.selfIllumMapEnable = ckb_lit_tgl.checked
					targetMat.selfIllumMapAmount = spn_lit_amt.value
				)
			)
		)
	)	 

	on btn_dif_getmap pressed do LoadBitmapToUI bm_dif_map etex_dif_name &file_dif
	on btn_dif_removemap pressed do ClearMapUI bm_dif_map etex_dif_name &file_dif
	on btn_nrm_getmap pressed do LoadBitmapToUI bm_nrm_map etex_nrm_name &file_nrm
	on btn_nrm_removemap pressed do ClearMapUI bm_nrm_map etex_nrm_name &file_nrm
	on btn_lit_getmap pressed do LoadBitmapToUI bm_lit_map etex_lit_name &file_lit
	on btn_lit_removemap pressed do ClearMapUI bm_lit_map etex_lit_name &file_lit
	
	on btn_spa_get pressed do
	(
		local str_spaMtlLib = getOpenFileName caption:"Select Material Library File" filename:g_MaterialLibPath types:"3dsMax material library file(*.mat)|*.mat|"
		if str_spaMtlLib != undefined do (
			loadMaterialLibrary str_spaMtlLib
			if currentMaterialLibrary.count > 0 do getMtlParameter currentMaterialLibrary[1]
		)
		col_pic.color = [spn_R_value.value, spn_G_value.value, spn_B_value.value]
	)
	
	on ddl_colLib selected sel_colIndex do
	(
		local arr_ColValue = case ddl_colLib.selected of
		(
			"Raw/Naked":	#(255,255,255); "White":		#(230,230,230)
			"Black":		#(35,35,35);    "Dark Gray":	#(60,60,60)
			default: #(255,255,255)
		)
		spn_R_value.value = arr_ColValue[1]; spn_G_value.value = arr_ColValue[2]; spn_B_value.value = arr_ColValue[3]
	)

	on ddl_matLib selected sel_mtlIndex do
	(
		local arr_MtlValue = case ddl_matLib.selected of
		(
			"Solid Paint (Gloss)":	#(20,50,100,0,255,255,255)
			"Glass (Clear)":		#(90,50,10,0,33,38,35)
			default: 				#(20,50,100,0,255,255,255)
		)
		spn_specular_value.value = arr_MtlValue[1]
		spn_Glossiness_value.value = arr_MtlValue[2]
		spn_opacity_value.value = arr_MtlValue[3]
		spn_selfIllum_value.value = arr_MtlValue[4]
		if(ckb_onlymtl_tgl.checked == true) do (
			spn_R_value.value = arr_MtlValue[5]; spn_G_value.value = arr_MtlValue[6]; spn_B_value.value = arr_MtlValue[7]
		)
	)

	on rltSubSM rolledUp isOpen do(if resizeCallback != undefined do resizeCallback())
)


--// ===================================================================================================
--// ROLLOUT: Physical Material
--// ===================================================================================================
rollout rltSubPM "Physical Material Maker" width:278 height:831
(
	local resizeCallback 
	
	local file_basec, file_rough, file_metal, file_trans, file_emit, file_nrm, file_difrough
	local thumb_black = bitmap 60 60 color:black
	
	local arr_ColorLiblary_List = #("Raw/Naked","White","Black","Dark Gray","Gray","Light Gray","Silver","Beige","Brown")
	local arr_MaterialLiblary_List = #("Tile/Stone (Gloss)","Tile/Stone (Matte)","Solid Paint (Gloss)","Solid Paint (Matte)","Metal (Gloss)","Glass (Clear)","Concrete","Fabric")
	
	checkbutton ckbtn_mtl_get "Pick Object Material" width:135 height:35 across:2 offset:[-5,0]
	button btn_mtl_set "Set Material" width:135 height:35  across:2 offset:[5,0]
	
	edittext etex_mtl_name text:"Material_Name" fieldWidth:145 height:20 readOnly:true offset:[-15,0]
	checkbox ckb_litmap_tgl "Process Lightmap" checked:false width:100 height:20 pos:[173,42]
	
	groupBox grp_mtl_spa "Load [ sp_assets ]" pos:[170,65] width:100 height:50 
	button btn_spa_get "Get Material" offset:[167,-38] width:80 height:25 align:#left
	dropdownlist ddl_colLib "Color Library" items:arr_ColorLiblary_List height:10 width:100 align:#left offset:[-10,-40] 
	dropdownlist ddl_matLib "Material Library" items:arr_MaterialLiblary_List height:10 width:150 align:#left offset:[-10,-3] 
	checkbox ckb_onlymtl_tgl "Include Color" checked:false offset:[70,-46] width:80 height:16 align:#left
	
	spinner spn_R_value "R:" range:[0,255,255] type:#integer fieldwidth: 30 offset:[85,-3] align:#right across:2
	spinner spn_floatR_value  range:[0.0,1.0,1.0] type:#float fieldwidth: 38 offset:[10,-3] align:#right
	spinner spn_G_value "G:" range:[0,255,255] type:#integer fieldwidth: 30 offset:[85,-3] align:#right across:2
	spinner spn_floatG_value  range:[0.0,1.0,1.0] type:#float fieldwidth: 38 offset:[10,-3] align:#right
	spinner spn_B_value "B:" range:[0,255,255] type:#integer fieldwidth: 30 offset:[85,0-3] align:#right across:2
	spinner spn_floatB_value  range:[0.0,1.0,1.0] type:#float fieldwidth: 38 offset:[10,0-3] align:#right
	colorpicker col_pic color:[255,255,255] width:110 height:25 offset:[10,-3] align:#right alpha:true

	label cmConvertTxt1 "Color Mode \nConversion: " height: 25 offset:[-2,-45] align:#left
	button LinTrgb "to sRGB" tooltip:"Linear to RGB (Brighten)" width: 75 align:#left offset:[65,-41]
	button rgbTLin "to Linear" tooltip:"RGB to Linear (Darken)" width: 75 align:#left offset:[65,0]

	-- Babylon Attributes
	groupBox extraAttrib "Extra Attributes" width:277 height:55 offset:[-13,-3]
	checkbox chUnlit "Unlit" tooltip:"Babylon Material Unlit" checked:false offset:[-2,-44] across:3
	checkbox backFaceCull "Back Face Culling" tooltip:"Babylon Material Backface Culling" checked:false offset:[-40,-44]
	dropdownlist transpMode "Transparecy Mode:" tooltip:"Babylon Transparency Mode" width:100 offset:[-10,-51] items:#("Opaque", "Cutoff", "Blend")
	
	-- Maps (Base Color)
	groupBox grp_mtl_BaseCol "Base Color Texture" pos:[0,265] width:277 height:80 align:#left
	bitmap bm_BaseCol_map "Base Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_BaseCol_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_BaseCol_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_BaseCol_amt "Amount:" range:[0.0,1.0,1.0] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_BaseCol_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_BaseCol_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_BaseCol_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_BaseCol_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_BaseCol_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right 
	
	-- Maps (Roughness)
	groupBox grp_mtl_rough "Roughness Texture" pos:[0,345] width:277 height:80 align:#left
	bitmap bm_rough_map "Rough Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_rough_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_rough_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_rough_amt "Amount:" range:[0.0,1.0,0.0] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_rough_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_rough_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_rough_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_rough_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_rough_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Maps (Metalness)
	groupBox grp_mtl_metal "Metalness Texture" pos:[0,425] width:277 height:80 align:#left
	bitmap bm_metal_map "Metal Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_metal_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_metal_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_metal_amt "Amount:" range:[0.0,1.0,0.0] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_metal_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_metal_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_metal_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_metal_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_metal_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Maps (Transparency)
	groupBox grp_mtl_trans "Transparency Texture" pos:[0,505] width:277 height:80 align:#left
	bitmap bm_trans_map "Trans Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_trans_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_trans_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_trans_amt "Amount:" range:[0.0,1.0,0.0] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_trans_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_trans_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_trans_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_trans_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_trans_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Maps (Emission)
	groupBox grp_mtl_emitCol "Emission Color Texture" pos:[0,585] width:277 height:80 align:#left
	bitmap bm_emissionCol_map "Emit Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_emissionCol_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_emissionCol_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	colorpicker emission_col_picker color:[1,1,1,1] alpha:true width:45 height:17 offset:[52,3]
	spinner spn_emissionCol_amt "" range:[0.0,1.0,0.0] type:#float fieldWidth:30 offset:[-5,-21] width:40 height:16 align:#center
	spinner spn_emissionCol_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_emissionCol_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_emissionCol_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_emissionCol_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_emissionCol_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Maps (Normal)
	groupBox grp_mtl_nrm "Bump Texture" pos:[0,665] width:277 height:80 align:#left
	bitmap bm_nrm_map "Bump Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_nrm_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_nrm_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_nrm_amt "Amount:" range:[0.0,10.0,0.3] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_nrm_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_nrm_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_nrm_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_nrm_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_nrm_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Maps (Diffuse Roughness / Lightmap)
	groupBox grp_mtl_difrough "Diff Roughness / Lightmap" pos:[0,745] width:277 height:80 align:#left
	bitmap bm_difrough_map "Lightmap" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_difrough_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_difrough_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_difrough_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,25] width:40 height:16 align:#center
	spinner spn_difrough_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_difrough_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_difrough_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_difrough_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	--// --- Helper Functions ---
	fn SyncColorSpinners r g b = (
		spn_R_value.value = r; spn_floatR_value.value = r/255.0
		spn_G_value.value = g; spn_floatG_value.value = g/255.0
		spn_B_value.value = b; spn_floatB_value.value = b/255.0
		col_pic.color = [r,g,b]
	)
	
	fn roundUp value = (if (value - (value as integer)) >= 0.5 then ceil value else floor value)
	
	fn rgb_to_linear value = (
		value = (value as float) / 255.0
		if value <= 0.04045 then (value / 12.92) * 255.0 else (((value + 0.055) / 1.055) ^ 2.4) * 255.0
	)

	fn linear_to_srgb value = (
		value = (value as float) / 255.0
		if value <= 0.0031308 then (value * 12.92) * 255.0 else (((value ^ (1.0/2.4)) * 1.055) - 0.055) * 255.0
	)
	
	fn UpdatePhysMapUI mapObj uiBmp uiTxt uiChk uiAmt uiU uiV uiRot &fileVar = (
		if mapObj != undefined and classof mapObj == Bitmaptexture then (
			try (
				local thumb = bitmap 60 60
				local temp = openbitmap (mapObj.filename as string)
				copy temp thumb
				uiBmp.bitmap = thumb
				uiTxt.text = filenameFromPath mapObj.filename
				fileVar = mapObj.filename
			) catch (
				uiBmp.bitmap = bitmap 60 60 color:red
				uiTxt.text = "Error/Missing"
			)
			uiChk.checked = true
			uiU.value = mapObj.coordinates.U_Tiling
			uiV.value = mapObj.coordinates.V_Tiling
			uiRot.value = mapObj.coordinates.W_Angle
		) else (
			uiBmp.bitmap = bitmap 60 60 color:black
			uiTxt.text = ""
			uiChk.checked = true
			uiU.value = 1.0; uiV.value = 1.0; uiRot.value = 0.0
			fileVar = undefined
		)
	)

	Fn getMtlParameter trgMtl =
	(
		if ((classof trgMtl) == PhysicalMaterial) then
		(
			SyncColorSpinners trgMtl.base_color.R trgMtl.base_color.G trgMtl.base_color.B
			spn_BaseCol_amt.value = trgMtl.base_weight
			spn_rough_amt.value = trgMtl.roughness
			spn_metal_amt.value = trgMtl.metalness
			spn_trans_amt.value = trgMtl.transparency
			spn_emissionCol_amt.value = trgMtl.emission
			emission_col_picker.color = trgMtl.emit_color
			spn_nrm_amt.value = trgMtl.bump_map_amt
			
			if isProperty trgMtl #Babylon_Attributes and trgMtl.Babylon_Attributes != undefined do
			(
				backFaceCull.checked = trgMtl.Babylon_Attributes.babylonBackfaceCulling
				chUnlit.checked = trgMtl.Babylon_Attributes.babylonUnlit
				transpMode.selection = trgMtl.Babylon_Attributes.babylonTransparencyMode + 1
			)
			
			local baseMap = trgMtl.base_color_map
			if classof baseMap == RGB_Multiply then (
				baseMap = baseMap.map1 
				SyncColorSpinners trgMtl.base_color_map.color2.R trgMtl.base_color_map.color2.G trgMtl.base_color_map.color2.B
			)
			
			UpdatePhysMapUI baseMap bm_BaseCol_map etex_BaseCol_name ckb_BaseCol_tgl spn_BaseCol_amt spn_BaseCol_u_til spn_BaseCol_v_til spn_BaseCol_w_rot &file_basec
			ckb_BaseCol_tgl.checked = trgMtl.base_color_map_on
			UpdatePhysMapUI trgMtl.roughness_map bm_rough_map etex_rough_name ckb_rough_tgl spn_rough_amt spn_rough_u_til spn_rough_v_til spn_rough_w_rot &file_rough
			ckb_rough_tgl.checked = trgMtl.roughness_map_on
			UpdatePhysMapUI trgMtl.metalness_map bm_metal_map etex_metal_name ckb_metal_tgl spn_metal_amt spn_metal_u_til spn_metal_v_til spn_metal_w_rot &file_metal
			ckb_metal_tgl.checked = trgMtl.metalness_map_on
			UpdatePhysMapUI trgMtl.transparency_map bm_trans_map etex_trans_name ckb_trans_tgl spn_trans_amt spn_trans_u_til spn_trans_v_til spn_trans_w_rot &file_trans
			ckb_trans_tgl.checked = trgMtl.transparency_map_on
			UpdatePhysMapUI trgMtl.emit_color_map bm_emissionCol_map etex_emissionCol_name ckb_emissionCol_tgl spn_emissionCol_amt spn_emissionCol_u_til spn_emissionCol_v_til spn_emissionCol_w_rot &file_emit
			ckb_emissionCol_tgl.checked = trgMtl.emit_color_map_on
			UpdatePhysMapUI trgMtl.bump_map bm_nrm_map etex_nrm_name ckb_nrm_tgl spn_nrm_amt spn_nrm_u_til spn_nrm_v_til spn_nrm_w_rot &file_nrm
			ckb_nrm_tgl.checked = trgMtl.bump_map_on
			UpdatePhysMapUI trgMtl.diff_rough_map bm_difrough_map etex_difrough_name ckb_difrough_tgl spn_difrough_u_til spn_difrough_u_til spn_difrough_v_til spn_difrough_w_rot &file_difrough
			ckb_difrough_tgl.checked = trgMtl.diff_rough_map_on
		)
		else( messageBox "Please select an object with Physical Material" )
	)
	
	fn fn_LoadMapUI uiBmp uiTxt &fileVar = (
		local bmp = selectBitMap()
		if bmp != undefined do (
			local t = bitmap 60 60
			copy bmp t
			uiBmp.bitmap = t
			uiTxt.text = filenameFromPath bmp.filename
			fileVar = bmp.filename
		)
	)
	
	fn fn_ClearMapUI uiBmp uiTxt &fileVar = (
		uiBmp.bitmap = bitmap 60 60 color:black; uiTxt.text = ""; fileVar = undefined
	)
	
	--// --- Event Handlers ---
	on rgbTLin pressed do (
		SyncColorSpinners (roundUp (rgb_to_linear col_pic.color.r)) (roundUp (rgb_to_linear col_pic.color.g)) (roundUp (rgb_to_linear col_pic.color.b))
	)
	on LinTrgb pressed do (
		SyncColorSpinners (roundUp (linear_to_srgb col_pic.color.r)) (roundUp (linear_to_srgb col_pic.color.g)) (roundUp (linear_to_srgb col_pic.color.b))
	)
	on col_pic changed col do SyncColorSpinners col.r col.g col.b
	on spn_R_value changed val do SyncColorSpinners val spn_G_value.value spn_B_value.value
	on spn_floatR_value changed val do SyncColorSpinners (val*255) spn_G_value.value spn_B_value.value
	
	on ckbtn_mtl_get changed state do 
	(
		local obj = pickObject()
		if isValidNode obj and obj.material != undefined do (
			etex_mtl_name.text = obj.material.name
			getMtlParameter obj.material
		)
		ckbtn_mtl_get.checked = false
	) 
	
	on btn_mtl_set pressed do 
	(
		undo "Set Physical Material" on 
		(
			for sel in selection where superclassof sel == geometryclass do 
			(
				local targetMat = sel.material
				if targetMat == undefined or classof targetMat != PhysicalMaterial then (
					local oldName = if targetMat != undefined then targetMat.name else "Physical_Mat"
					targetMat = PhysicalMaterial name:oldName
					sel.material = targetMat
				)
				
				targetMat.showInViewport = true
				targetMat.base_color = col_pic.color
				targetMat.base_weight = spn_BaseCol_amt.value
				targetMat.roughness = spn_rough_amt.value
				targetMat.metalness = spn_metal_amt.value
				targetMat.transparency = spn_trans_amt.value
				targetMat.emission = spn_emissionCol_amt.value
				targetMat.emit_color = emission_col_picker.color
				targetMat.bump_map_amt = spn_nrm_amt.value
				
				if isProperty targetMat #Babylon_Attributes do (
					targetMat.Babylon_Attributes.babylonTransparencyMode = transpMode.selection - 1
					targetMat.Babylon_Attributes.babylonBackfaceCulling = backFaceCull.checked
					targetMat.Babylon_Attributes.babylonUnlit = chUnlit.checked
				)
				
				fn AssignPTexture mapSlot uiChk uiU uiV uiRot fileName isBase:false = (
					if fileName != undefined and fileName != "" then (
						local map = if classof mapSlot == BitmapTexture then mapSlot else BitmapTexture()
						if isBase then (
							local mult = RGB_Multiply()
							mult.map1 = map
							mult.color2 = col_pic.color
							mapSlot = mult 
						) else mapSlot = map
						map.filename = fileName
						map.coordinates.U_Tiling = uiU
						map.coordinates.V_Tiling = uiV
						map.coordinates.W_Angle = uiRot
						return mapSlot
					)
					return undefined
				)
				
				if file_basec != undefined then (
					local bm = BitmapTexture filename:file_basec
					bm.coordinates.U_Tiling = spn_BaseCol_u_til.value
					bm.coordinates.V_Tiling = spn_BaseCol_v_til.value
					bm.coordinates.W_Angle = spn_BaseCol_w_rot.value
					local mult = RGB_Multiply()
					mult.map1 = bm; mult.color2 = col_pic.color 
					targetMat.base_color_map = mult
				) else targetMat.base_color_map = undefined
				targetMat.base_color_map_on = ckb_BaseCol_tgl.checked

				targetMat.roughness_map = AssignPTexture targetMat.roughness_map ckb_rough_tgl.checked spn_rough_u_til.value spn_rough_v_til.value spn_rough_w_rot.value file_rough
				targetMat.roughness_map_on = ckb_rough_tgl.checked
				targetMat.metalness_map = AssignPTexture targetMat.metalness_map ckb_metal_tgl.checked spn_metal_u_til.value spn_metal_v_til.value spn_metal_w_rot.value file_metal
				targetMat.metalness_map_on = ckb_metal_tgl.checked
				targetMat.transparency_map = AssignPTexture targetMat.transparency_map ckb_trans_tgl.checked spn_trans_u_til.value spn_trans_v_til.value spn_trans_w_rot.value file_trans
				targetMat.transparency_map_on = ckb_trans_tgl.checked
				targetMat.emit_color_map = AssignPTexture targetMat.emit_color_map ckb_emissionCol_tgl.checked spn_emissionCol_u_til.value spn_emissionCol_v_til.value spn_emissionCol_w_rot.value file_emit
				targetMat.emit_color_map_on = ckb_emissionCol_tgl.checked
				targetMat.bump_map = AssignPTexture targetMat.bump_map ckb_nrm_tgl.checked spn_nrm_u_til.value spn_nrm_v_til.value spn_nrm_w_rot.value file_nrm
				targetMat.bump_map_on = ckb_nrm_tgl.checked
				if ckb_litmap_tgl.checked do (
					targetMat.diff_rough_map = AssignPTexture targetMat.diff_rough_map ckb_difrough_tgl.checked spn_difrough_u_til.value spn_difrough_v_til.value spn_difrough_w_rot.value file_difrough
					if targetMat.diff_rough_map != undefined do targetMat.diff_rough_map.coords.mapChannel = 2
				)
			)
		)
	)	 

	on btn_BaseCol_getmap pressed do fn_LoadMapUI bm_BaseCol_map etex_BaseCol_name &file_basec
	on btn_BaseCol_removemap pressed do fn_ClearMapUI bm_BaseCol_map etex_BaseCol_name &file_basec
	on btn_rough_getmap pressed do fn_LoadMapUI bm_rough_map etex_rough_name &file_rough
	on btn_rough_removemap pressed do fn_ClearMapUI bm_rough_map etex_rough_name &file_rough
	on btn_metal_getmap pressed do fn_LoadMapUI bm_metal_map etex_metal_name &file_metal
	on btn_metal_removemap pressed do fn_ClearMapUI bm_metal_map etex_metal_name &file_metal
	on btn_trans_getmap pressed do fn_LoadMapUI bm_trans_map etex_trans_name &file_trans
	on btn_trans_removemap pressed do fn_ClearMapUI bm_trans_map etex_trans_name &file_trans
	on btn_emissionCol_getmap pressed do fn_LoadMapUI bm_emissionCol_map etex_emissionCol_name &file_emit
	on btn_emissionCol_removemap pressed do fn_ClearMapUI bm_emissionCol_map etex_emissionCol_name &file_emit
	on btn_nrm_getmap pressed do fn_LoadMapUI bm_nrm_map etex_nrm_name &file_nrm
	on btn_nrm_removemap pressed do fn_ClearMapUI bm_nrm_map etex_nrm_name &file_nrm
	on btn_difrough_getmap pressed do fn_LoadMapUI bm_difrough_map etex_difrough_name &file_difrough
	on btn_difrough_removemap pressed do fn_ClearMapUI bm_difrough_map etex_difrough_name &file_difrough
	
	on btn_spa_get pressed do
	(
		local str_spaMtlLib = getOpenFileName caption:"Select Material Library File" filename:g_MaterialLibPath types:"3dsMax material library file(*.mat)|*.mat|"
		if str_spaMtlLib != undefined do (
			loadMaterialLibrary str_spaMtlLib
			if currentMaterialLibrary.count > 0 do getMtlParameter currentMaterialLibrary[1]
		)
	)
	
	on ddl_colLib selected sel_colIndex do (
		local arr_ColValue = case ddl_colLib.selected of (
			"White":#(230,230,230); "Black":#(35,35,35); "Gray":#(128,128,128); default:#(255,255,255)
		)
		SyncColorSpinners arr_ColValue[1] arr_ColValue[2] arr_ColValue[3]
	)

	on ddl_matLib selected sel_mtlIndex do (
		local arr = case ddl_matLib.selected of (
			"Mirror": #(0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0)
			"Glass (Clear)": #(0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0)
			default: #(0.75, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
		)
		spn_rough_amt.value = arr[1]; spn_metal_amt.value = arr[2]
		spn_trans_amt.value = arr[3]; spn_emissionCol_amt.value = arr[4]
		if ckb_onlymtl_tgl.checked do SyncColorSpinners (arr[5]*255) (arr[6]*255) (arr[7]*255)
	)

	on rltSubPM rolledUp isOpen do(if resizeCallback != undefined do resizeCallback())
)

--// ===================================================================================================
--// ROLLOUT: VRay Material (VRay 7 / PBR Workflow)
--// ===================================================================================================
rollout rltSubVM "VRay Material Maker" width:278 height:770
(
	local resizeCallback 
	
	-- Variables for texture paths
	local file_diffuse, file_rough, file_metal, file_refract, file_selfillum, file_bump, file_lightmap
	local thumb_black = bitmap 60 60 color:black
	
	-- Libraries
	local arr_ColorLiblary_List = #("Raw/Naked","White","Black","Dark Gray","Gray","Light Gray","Silver","Beige","Brown")
	local arr_MaterialLiblary_List = #("Tile/Stone (Gloss)","Tile/Stone (Matte)","Solid Paint (Gloss)","Solid Paint (Matte)","Metal (Gloss)","Glass (Clear)","Concrete","Fabric")
	
	-- Material Controls
	checkbutton ckbtn_mtl_get "Pick Object Material" width:135 height:35 across:2 offset:[-5,0]
	button btn_mtl_set "Set Material" width:135 height:35  across:2 offset:[5,0]
	
	edittext etex_mtl_name text:"Material_Name" fieldWidth:145 height:20 readOnly:true offset:[-15,0]
	checkbox ckb_litmap_tgl "Process Lightmap" checked:false width:100 height:20 pos:[173,42]
	
	groupBox grp_mtl_spa "Load [ sp_assets ]" pos:[170,65] width:100 height:50 
	button btn_spa_get "Get Material" offset:[167,-38] width:80 height:25 align:#left
	dropdownlist ddl_colLib "Color Library" items:arr_ColorLiblary_List height:10 width:100 align:#left offset:[-10,-40] 
	dropdownlist ddl_matLib "Material Library" items:arr_MaterialLiblary_List height:10 width:150 align:#left offset:[-10,-3] 
	checkbox ckb_onlymtl_tgl "Include Color" checked:false offset:[70,-46] width:80 height:16 align:#left
	
	-- Colors
	spinner spn_R_value "R:" range:[0,255,255] type:#integer fieldwidth: 30 offset:[85,-3] align:#right across:2
	spinner spn_floatR_value  range:[0.0,1.0,1.0] type:#float fieldwidth: 38 offset:[10,-3] align:#right
	spinner spn_G_value "G:" range:[0,255,255] type:#integer fieldwidth: 30 offset:[85,-3] align:#right across:2
	spinner spn_floatG_value  range:[0.0,1.0,1.0] type:#float fieldwidth: 38 offset:[10,-3] align:#right
	spinner spn_B_value "B:" range:[0,255,255] type:#integer fieldwidth: 30 offset:[85,0-3] align:#right across:2
	spinner spn_floatB_value  range:[0.0,1.0,1.0] type:#float fieldwidth: 38 offset:[10,0-3] align:#right
	colorpicker col_pic color:[255,255,255] width:110 height:25 offset:[10,-3] align:#right alpha:true

	label cmConvertTxt1 "Color Mode \nConversion: " height: 25 offset:[-2,-45] align:#left
	button LinTrgb "to sRGB" tooltip:"Linear to RGB (Brighten)" width: 75 align:#left offset:[65,-41]
	button rgbTLin "to Linear" tooltip:"RGB to Linear (Darken)" width: 75 align:#left offset:[65,0]

	-- Diffuse (Base Color)
	groupBox grp_mtl_dif "Diffuse Texture" pos:[0,210] width:277 height:80 align:#left
	bitmap bm_dif_map "Diffuse Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_dif_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_dif_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_dif_amt "Amount:" range:[0.0,1.0,1.0] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_dif_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_dif_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_dif_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_dif_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_dif_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right 
	
	-- Roughness
	groupBox grp_mtl_rough "Roughness Texture" pos:[0,290] width:277 height:80 align:#left
	bitmap bm_rough_map "Rough Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_rough_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_rough_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_rough_amt "Amount:" range:[0.0,1.0,0.0] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_rough_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_rough_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_rough_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_rough_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_rough_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Metalness
	groupBox grp_mtl_metal "Metalness Texture" pos:[0,370] width:277 height:80 align:#left
	bitmap bm_metal_map "Metal Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_metal_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_metal_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_metal_amt "Amount:" range:[0.0,1.0,0.0] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_metal_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_metal_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_metal_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_metal_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_metal_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Refraction (Transparency)
	groupBox grp_mtl_trans "Refraction Texture" pos:[0,450] width:277 height:80 align:#left
	bitmap bm_trans_map "Refract Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_trans_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_trans_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_trans_amt "Amount:" range:[0.0,1.0,0.0] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_trans_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_trans_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_trans_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_trans_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_trans_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Self Illumination
	groupBox grp_mtl_emitCol "Self Illumination" pos:[0,530] width:277 height:80 align:#left
	bitmap bm_emissionCol_map "Emit Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_emissionCol_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_emissionCol_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	colorpicker emission_col_picker color:[0,0,0,1] alpha:true width:45 height:17 offset:[52,3]
	spinner spn_emissionCol_amt "" range:[0.0,100.0,1.0] type:#float fieldWidth:30 offset:[-5,-21] width:40 height:16 align:#center
	spinner spn_emissionCol_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_emissionCol_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_emissionCol_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_emissionCol_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_emissionCol_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Bump / Normal
	groupBox grp_mtl_nrm "Bump Texture" pos:[0,610] width:277 height:80 align:#left
	bitmap bm_nrm_map "Bump Map" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_nrm_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_nrm_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_nrm_amt "Amount:" range:[0.0,100.0,30.0] type:#float fieldWidth:30 offset:[-5,4] width:40 height:16 align:#center
	spinner spn_nrm_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,0] width:40 height:16 align:#center
	spinner spn_nrm_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_nrm_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_nrm_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_nrm_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	-- Lightmap (Extra channel)
	groupBox grp_mtl_difrough "Lightmap (Channel 2)" pos:[0,690] width:277 height:80 align:#left
	bitmap bm_difrough_map "Lightmap" bitmap:thumb_black offset:[-8,-70] width:60 height:60 align:#left
	edittext etex_difrough_name text:"" fieldWidth:150 height:20 readOnly:true offset:[55,-72] align:#center
	checkbox ckb_difrough_tgl "Enable" checked:true offset:[-44,-24] width:50 height:16 align:#center
	spinner spn_difrough_u_til "U:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[-35,25] width:40 height:16 align:#center
	spinner spn_difrough_v_til "V:" range:[0.0,128.0,1.0] type:#float fieldWidth:30 offset:[35,-21] width:40 height:16 align:#center
	spinner spn_difrough_w_rot "Rot:" range:[0,90,0] type:#float fieldWidth:30 offset:[112,-21] width:40 height:16 align:#center
	button btn_difrough_getmap "Get" width:55 height:20 offset:[-50,-44] align:#right
	button btn_difrough_removemap "Remove" width:55 height:20 offset:[7,-25] align:#right
	
	--// --- Helper Functions ---
	fn SyncColorSpinners r g b = (
		spn_R_value.value = r; spn_floatR_value.value = r/255.0
		spn_G_value.value = g; spn_floatG_value.value = g/255.0
		spn_B_value.value = b; spn_floatB_value.value = b/255.0
		col_pic.color = [r,g,b]
	)
	
	fn roundUp value = (if (value - (value as integer)) >= 0.5 then ceil value else floor value)
	fn rgb_to_linear value = (
		value = (value as float) / 255.0
		if value <= 0.04045 then (value / 12.92) * 255.0 else (((value + 0.055) / 1.055) ^ 2.4) * 255.0
	)
	fn linear_to_srgb value = (
		value = (value as float) / 255.0
		if value <= 0.0031308 then (value * 12.92) * 255.0 else (((value ^ (1.0/2.4)) * 1.055) - 0.055) * 255.0
	)
	
	fn UpdateVRayMapUI mapObj uiBmp uiTxt uiChk uiU uiV uiRot &fileVar = (
		if mapObj != undefined and classof mapObj == Bitmaptexture then (
			try (
				local thumb = bitmap 60 60
				local temp = openbitmap (mapObj.filename as string)
				copy temp thumb
				uiBmp.bitmap = thumb
				uiTxt.text = filenameFromPath mapObj.filename
				fileVar = mapObj.filename
			) catch (
				uiBmp.bitmap = bitmap 60 60 color:red; uiTxt.text = "Error/Missing"
			)
			uiChk.checked = true
			uiU.value = mapObj.coordinates.U_Tiling
			uiV.value = mapObj.coordinates.V_Tiling
			uiRot.value = mapObj.coordinates.W_Angle
		) else (
			uiBmp.bitmap = bitmap 60 60 color:black; uiTxt.text = ""
			uiChk.checked = false -- VRay maps default off if missing
			uiU.value = 1.0; uiV.value = 1.0; uiRot.value = 0.0
			fileVar = undefined
		)
	)
	
	-- Helper to create map
	fn AssignVRayTexture mapSlot uiChk uiU uiV uiRot fileName = (
		if fileName != undefined and fileName != "" then (
			local map = if classof mapSlot == BitmapTexture then mapSlot else BitmapTexture()
			map.filename = fileName
			map.coordinates.U_Tiling = uiU
			map.coordinates.V_Tiling = uiV
			map.coordinates.W_Angle = uiRot
			return map
		)
		return undefined
	)
	
	fn fn_LoadMapUI uiBmp uiTxt &fileVar = (
		local bmp = selectBitMap()
		if bmp != undefined do (
			local t = bitmap 60 60; copy bmp t; uiBmp.bitmap = t
			uiTxt.text = filenameFromPath bmp.filename; fileVar = bmp.filename
		)
	)
	
	fn fn_ClearMapUI uiBmp uiTxt &fileVar = (
		uiBmp.bitmap = bitmap 60 60 color:black; uiTxt.text = ""; fileVar = undefined
	)
	
	Fn getMtlParameter trgMtl =
	(
		if ((classof trgMtl) == VRayMtl) then
		(
			SyncColorSpinners trgMtl.diffuse.R trgMtl.diffuse.G trgMtl.diffuse.B
			
			-- Values (Handle Roughness toggle)
			local roughVal = if (isProperty trgMtl #brdf_useRoughness and trgMtl.brdf_useRoughness) then trgMtl.roughness else (1.0 - trgMtl.reflection_glossiness)
			spn_rough_amt.value = roughVal
			spn_metal_amt.value = trgMtl.metalness
			
			-- Refraction is color based, take value from color intensity or refraction_amount if existing
			spn_trans_amt.value = (trgMtl.refraction.v / 255.0) 
			
			spn_emissionCol_amt.value = trgMtl.selfIllumination_multiplier
			emission_col_picker.color = trgMtl.selfIllumination
			
			spn_nrm_amt.value = trgMtl.texmap_bump_multiplier
			
			-- Maps
			UpdateVRayMapUI trgMtl.texmap_diffuse bm_dif_map etex_dif_name ckb_dif_tgl spn_dif_u_til spn_dif_v_til spn_dif_w_rot &file_diffuse
			if isProperty trgMtl #texmap_diffuse_on do ckb_dif_tgl.checked = trgMtl.texmap_diffuse_on
			
			UpdateVRayMapUI trgMtl.texmap_roughness bm_rough_map etex_rough_name ckb_rough_tgl spn_rough_u_til spn_rough_v_til spn_rough_w_rot &file_rough
			if isProperty trgMtl #texmap_roughness_on do ckb_rough_tgl.checked = trgMtl.texmap_roughness_on
			
			UpdateVRayMapUI trgMtl.texmap_metalness bm_metal_map etex_metal_name ckb_metal_tgl spn_metal_u_til spn_metal_v_til spn_metal_w_rot &file_metal
			if isProperty trgMtl #texmap_metalness_on do ckb_metal_tgl.checked = trgMtl.texmap_metalness_on
			
			UpdateVRayMapUI trgMtl.texmap_refraction bm_trans_map etex_trans_name ckb_trans_tgl spn_trans_u_til spn_trans_v_til spn_trans_w_rot &file_refract
			if isProperty trgMtl #texmap_refraction_on do ckb_trans_tgl.checked = trgMtl.texmap_refraction_on
			
			UpdateVRayMapUI trgMtl.texmap_self_illumination bm_emissionCol_map etex_emissionCol_name ckb_emissionCol_tgl spn_emissionCol_u_til spn_emissionCol_v_til spn_emissionCol_w_rot &file_selfillum
			if isProperty trgMtl #texmap_self_illumination_on do ckb_emissionCol_tgl.checked = trgMtl.texmap_self_illumination_on
			
			UpdateVRayMapUI trgMtl.texmap_bump bm_nrm_map etex_nrm_name ckb_nrm_tgl spn_nrm_u_til spn_nrm_v_til spn_nrm_w_rot &file_bump
			if isProperty trgMtl #texmap_bump_on do ckb_nrm_tgl.checked = trgMtl.texmap_bump_on
		)
		else( messageBox "Please select an object with VRay Material" )
	)
	
	--// --- Event Handlers ---
	on rgbTLin pressed do (
		SyncColorSpinners (roundUp (rgb_to_linear col_pic.color.r)) (roundUp (rgb_to_linear col_pic.color.g)) (roundUp (rgb_to_linear col_pic.color.b))
	)
	on LinTrgb pressed do (
		SyncColorSpinners (roundUp (linear_to_srgb col_pic.color.r)) (roundUp (linear_to_srgb col_pic.color.g)) (roundUp (linear_to_srgb col_pic.color.b))
	)
	on col_pic changed col do SyncColorSpinners col.r col.g col.b
	on spn_R_value changed val do SyncColorSpinners val spn_G_value.value spn_B_value.value
	on spn_floatR_value changed val do SyncColorSpinners (val*255) spn_G_value.value spn_B_value.value
	
	on ckbtn_mtl_get changed state do 
	(
		local obj = pickObject()
		if isValidNode obj and obj.material != undefined do (
			etex_mtl_name.text = obj.material.name
			getMtlParameter obj.material
		)
		ckbtn_mtl_get.checked = false
	) 
	
	on btn_mtl_set pressed do 
	(
		undo "Set VRay Material" on 
		(
			for sel in selection where superclassof sel == geometryclass do 
			(
				local targetMat = sel.material
				
				-- Ensure VRay Material
				if targetMat == undefined or classof targetMat != VRayMtl then (
					local oldName = if targetMat != undefined then targetMat.name else "VRay_Mat"
					targetMat = VRayMtl name:oldName
					sel.material = targetMat
				)
				
				targetMat.showInViewport = true
				
				-- Set to Roughness Mode for PBR compatibility
				if isProperty targetMat #brdf_useRoughness do targetMat.brdf_useRoughness = true
				
				targetMat.diffuse = col_pic.color
				targetMat.roughness = spn_rough_amt.value
				targetMat.metalness = spn_metal_amt.value
				
				-- Refraction (Transparency) logic
				local transVal = (spn_trans_amt.value * 255) as integer
				targetMat.refraction = color transVal transVal transVal
				
				targetMat.selfIllumination_multiplier = spn_emissionCol_amt.value
				targetMat.selfIllumination = emission_col_picker.color
				
				targetMat.texmap_bump_multiplier = spn_nrm_amt.value
				
				-- Apply Maps
				targetMat.texmap_diffuse = AssignVRayTexture targetMat.texmap_diffuse ckb_dif_tgl.checked spn_dif_u_til.value spn_dif_v_til.value spn_dif_w_rot.value file_diffuse
				if isProperty targetMat #texmap_diffuse_on do targetMat.texmap_diffuse_on = ckb_dif_tgl.checked
				
				targetMat.texmap_roughness = AssignVRayTexture targetMat.texmap_roughness ckb_rough_tgl.checked spn_rough_u_til.value spn_rough_v_til.value spn_rough_w_rot.value file_rough
				if isProperty targetMat #texmap_roughness_on do targetMat.texmap_roughness_on = ckb_rough_tgl.checked
				
				targetMat.texmap_metalness = AssignVRayTexture targetMat.texmap_metalness ckb_metal_tgl.checked spn_metal_u_til.value spn_metal_v_til.value spn_metal_w_rot.value file_metal
				if isProperty targetMat #texmap_metalness_on do targetMat.texmap_metalness_on = ckb_metal_tgl.checked
				
				targetMat.texmap_refraction = AssignVRayTexture targetMat.texmap_refraction ckb_trans_tgl.checked spn_trans_u_til.value spn_trans_v_til.value spn_trans_w_rot.value file_refract
				if isProperty targetMat #texmap_refraction_on do targetMat.texmap_refraction_on = ckb_trans_tgl.checked
				
				targetMat.texmap_self_illumination = AssignVRayTexture targetMat.texmap_self_illumination ckb_emissionCol_tgl.checked spn_emissionCol_u_til.value spn_emissionCol_v_til.value spn_emissionCol_w_rot.value file_selfillum
				if isProperty targetMat #texmap_self_illumination_on do targetMat.texmap_self_illumination_on = ckb_emissionCol_tgl.checked
				
				targetMat.texmap_bump = AssignVRayTexture targetMat.texmap_bump ckb_nrm_tgl.checked spn_nrm_u_til.value spn_nrm_v_til.value spn_nrm_w_rot.value file_bump
				if isProperty targetMat #texmap_bump_on do targetMat.texmap_bump_on = ckb_nrm_tgl.checked
				
				-- Lightmap Processing (Custom logic)
				if ckb_litmap_tgl.checked do (
					-- VRay doesn't have a direct "Lightmap" slot, putting it in Diffuse channel 2 or using it for baking
					-- Here we just assign a bitmap to be available for later use, or user logic
					-- Since VRay 7 doesn't have a specific "Lightmap" slot, we skip assignment to avoid errors, 
					-- but keep the file variable available if needed for baking scripts.
				)
			)
		)
	)	

	on btn_dif_getmap pressed do fn_LoadMapUI bm_dif_map etex_dif_name &file_diffuse
	on btn_dif_removemap pressed do fn_ClearMapUI bm_dif_map etex_dif_name &file_diffuse
	on btn_rough_getmap pressed do fn_LoadMapUI bm_rough_map etex_rough_name &file_rough
	on btn_rough_removemap pressed do fn_ClearMapUI bm_rough_map etex_rough_name &file_rough
	on btn_metal_getmap pressed do fn_LoadMapUI bm_metal_map etex_metal_name &file_metal
	on btn_metal_removemap pressed do fn_ClearMapUI bm_metal_map etex_metal_name &file_metal
	on btn_trans_getmap pressed do fn_LoadMapUI bm_trans_map etex_trans_name &file_refract
	on btn_trans_removemap pressed do fn_ClearMapUI bm_trans_map etex_trans_name &file_refract
	on btn_emissionCol_getmap pressed do fn_LoadMapUI bm_emissionCol_map etex_emissionCol_name &file_selfillum
	on btn_emissionCol_removemap pressed do fn_ClearMapUI bm_emissionCol_map etex_emissionCol_name &file_selfillum
	on btn_nrm_getmap pressed do fn_LoadMapUI bm_nrm_map etex_nrm_name &file_bump
	on btn_nrm_removemap pressed do fn_ClearMapUI bm_nrm_map etex_nrm_name &file_bump
	on btn_difrough_getmap pressed do fn_LoadMapUI bm_difrough_map etex_difrough_name &file_lightmap
	on btn_difrough_removemap pressed do fn_ClearMapUI bm_difrough_map etex_difrough_name &file_lightmap
	
	on btn_spa_get pressed do
	(
		local str_spaMtlLib = getOpenFileName caption:"Select Material Library File" filename:g_MaterialLibPath types:"3dsMax material library file(*.mat)|*.mat|"
		if str_spaMtlLib != undefined do (
			loadMaterialLibrary str_spaMtlLib
			if currentMaterialLibrary.count > 0 do getMtlParameter currentMaterialLibrary[1]
		)
	)
	
	on ddl_colLib selected sel_colIndex do (
		local arr_ColValue = case ddl_colLib.selected of (
			"White":#(230,230,230); "Black":#(35,35,35); "Gray":#(128,128,128); default:#(255,255,255)
		)
		SyncColorSpinners arr_ColValue[1] arr_ColValue[2] arr_ColValue[3]
	)

	on ddl_matLib selected sel_mtlIndex do (
		local arr = case ddl_matLib.selected of (
			"Mirror": #(0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0)
			"Glass (Clear)": #(0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0)
			default: #(0.75, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
		)
		spn_rough_amt.value = arr[1]; spn_metal_amt.value = arr[2]
		spn_trans_amt.value = arr[3]; spn_emissionCol_amt.value = arr[4]
		if ckb_onlymtl_tgl.checked do SyncColorSpinners (arr[5]*255) (arr[6]*255) (arr[7]*255)
	)

	on rltSubVM rolledUp isOpen do(if resizeCallback != undefined do resizeCallback())
)

--// ===================================================================================================
--// MAIN ROLLOUT CONTAINER
--// ===================================================================================================
rollout roMain "Material Editor" width:335 height:400
(
    local leftColWidth = 40
    local subROPos = [leftColWidth + 5, 5]
    local subROWidth = 290
    
    -- Main Toggle Buttons
    checkButton chbShowP "P\nH\nY" checked:on width:35 height:80 pos:[5,5] highlightColor:orange tooltip:"Show Physical Material Editor"
    checkButton chbShowV "V\nR\nA\nY" checked:off width:35 height:80 pos:[5,90] highlightColor:green tooltip:"Show VRay Material Editor"
	checkButton chbShowS "S\nT\nD" checked:off width:35 height:80 pos:[5,175] highlightColor:blue tooltip:"Show Standard Material Editor"
    
    -- SubRollout Container
    subRollout SubHolder "" height:300 width:subROWidth pos:subROPos

    -- Function: Resize window dynamically based on content
    fn resize =
    (
        local totalH = 0
        if SubHolder.rollouts.count > 0 do (
            for ro in SubHolder.rollouts do (
                totalH += (if ro.open then ro.height + 25 else 25)
            )
        )
        SubHolder.height = totalH + 5
        roMain.height = amin (totalH + 15) 950 -- Clamp max height to avoid offscreen
    )

    -- Function: Switch active rollout
    fn switchRollout type = (
        for ro in SubHolder.rollouts do removeSubRollout SubHolder ro
        
		case type of (
			#phys: (
				addSubRollout SubHolder rltSubPM
				rltSubPM.resizeCallback = resize
			)
			#vray: (
				addSubRollout SubHolder rltSubVM
				rltSubVM.resizeCallback = resize
			)
			#std: (
				addSubRollout SubHolder rltSubSM
				rltSubSM.resizeCallback = resize
			)
		)
        resize()
    )
    
    on roMain open do switchRollout #phys
    
    on chbShowP changed state do (
        if state then (
            chbShowS.state = false; chbShowV.state = false
            switchRollout #phys
        ) else chbShowP.state = true 
    )
	
	on chbShowV changed state do (
        if state then (
            chbShowS.state = false; chbShowP.state = false
            switchRollout #vray
        ) else chbShowV.state = true 
    )
    
    on chbShowS changed state do (
        if state then (
            chbShowP.state = false; chbShowV.state = false
            switchRollout #std
        ) else chbShowS.state = true
    )
)

createDialog roMain style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
