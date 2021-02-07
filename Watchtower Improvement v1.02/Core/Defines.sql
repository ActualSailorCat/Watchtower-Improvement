--==========================================================================================================================
-- Watchtower Improvement by SailorCat
--==========================================================================================================================
-----------------------------------------------
-- Improvements
-----------------------------------------------
INSERT INTO Types (Type, Kind) VALUES ('IMPROVEMENT_SAILOR_WATCHTOWER', 'KIND_IMPROVEMENT');
INSERT INTO Improvements	(
		ImprovementType,
		Name,		
		Description,
		Icon,
		Buildable,
		PlunderType,
		TilesRequired,
		SameAdjacentValid,
		Domain,		
		CanBuildOutsideTerritory
		)
VALUES  (
		'IMPROVEMENT_SAILOR_WATCHTOWER', -- ImprovementType
		'LOC_IMPROVEMENT_SAILOR_WATCHTOWER_NAME', -- Name		
		'LOC_IMPROVEMENT_SAILOR_WATCHTOWER_DESCRIPTION', -- Description
		'ICON_IMPROVEMENT_SAILOR_WATCHTOWER', -- Icon
		1, -- Buildable
		'NO_PLUNDER',
		1, -- TilesRequired
		1, -- SameAdjacentValid
		'DOMAIN_LAND', -- Domain
		1 -- CanBuildOutsideTerritory
		);
-----------------------------------------------
-- Improvement_ValidBuildUnits
-----------------------------------------------
INSERT INTO Improvement_ValidBuildUnits
		(ImprovementType,					UnitType)
SELECT	'IMPROVEMENT_SAILOR_WATCHTOWER',	UnitType
FROM Units WHERE PromotionClass = 'PROMOTION_CLASS_RECON' AND Domain = 'DOMAIN_LAND';
-----------------------------------------------
-- Improvement_ValidTerrains
-----------------------------------------------
INSERT INTO Improvement_ValidTerrains
		(ImprovementType,					TerrainType)
SELECT	'IMPROVEMENT_SAILOR_WATCHTOWER',	TerrainType
FROM Terrains WHERE Water != 1 AND Mountain != 1;
-----------------------------------------------
-- Improvement_ValidFeatures
-----------------------------------------------
INSERT INTO Improvement_ValidFeatures
		(ImprovementType,					FeatureType)
SELECT	'IMPROVEMENT_SAILOR_WATCHTOWER',	FeatureType
FROM Features WHERE Coast = 0 AND NaturalWonder = 0 AND FeatureType NOT IN (SELECT FeatureType FROM Feature_ValidTerrains WHERE TerrainType = 'TERRAIN_COAST') AND FeatureType NOT LIKE '%VOLCAN%' AND FeatureType != 'FEATURE_GEOTHERMAL_FISSURE';
-----------------------------------------------
-- DynamicModifiers
-----------------------------------------------
INSERT INTO Types (Type, Kind) VALUES ('MODIFIER_SAILOR_WATCHTOWER_SIGHT_ADJUST', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType) VALUES ('MODIFIER_SAILOR_WATCHTOWER_SIGHT_ADJUST', 'COLLECTION_OWNER', 'EFFECT_ADJUST_UNIT_SIGHT');
-----------------------------------------------
-- Units
-----------------------------------------------
UPDATE UnitCommands SET CategoryInUI = 'SECONDARY' WHERE CommandType = 'UNITCOMMAND_PRIORITY_TARGET'; -- SpecOps UI Overflow Adjustment
UPDATE Units SET BuildCharges = 1 WHERE BuildCharges = 0 AND PromotionClass = 'PROMOTION_CLASS_RECON' AND Domain = 'DOMAIN_LAND';
INSERT INTO UnitAiInfos (UnitType, AiType) SELECT UnitType, 'UNITAI_BUILD'
FROM Units WHERE PromotionClass = 'PROMOTION_CLASS_RECON' AND UnitType NOT IN (SELECT UnitType FROM UnitAiInfos WHERE AiType = 'UNITAI_BUILD') AND Domain = 'DOMAIN_LAND';
-----------------------------------------------
-- UnitAbilities
-----------------------------------------------
INSERT INTO Types
		(Type,											Kind)
VALUES	('ABILITY_SAILOR_WATCHTOWER_MAJOR_SIGHT_BONUS',	'KIND_ABILITY'),
		('ABILITY_SAILOR_WATCHTOWER_MINOR_SIGHT_BONUS',	'KIND_ABILITY');

INSERT INTO TypeTags (Type, Tag) SELECT DISTINCT 'ABILITY_SAILOR_WATCHTOWER_MAJOR_SIGHT_BONUS', Tag FROM TypeTags WHERE Type IN (SELECT UnitType FROM Units WHERE Domain = 'DOMAIN_LAND');
INSERT INTO TypeTags (Type, Tag) SELECT DISTINCT 'ABILITY_SAILOR_WATCHTOWER_MINOR_SIGHT_BONUS', Tag FROM TypeTags WHERE Type IN (SELECT UnitType FROM Units WHERE Domain = 'DOMAIN_LAND');

INSERT INTO UnitAbilities
		(UnitAbilityType,								Inactive)
VALUES	('ABILITY_SAILOR_WATCHTOWER_MAJOR_SIGHT_BONUS',	0),
		('ABILITY_SAILOR_WATCHTOWER_MINOR_SIGHT_BONUS',	0);
-----------------------------------------------
-- Modifiers
-----------------------------------------------
INSERT INTO	UnitAbilityModifiers
		(UnitAbilityType, ModifierId)
VALUES	('ABILITY_SAILOR_WATCHTOWER_MAJOR_SIGHT_BONUS', 'SAILOR_WATCHTOWER_MAJOR_SIGHT_MOD'),
		('ABILITY_SAILOR_WATCHTOWER_MINOR_SIGHT_BONUS', 'SAILOR_WATCHTOWER_MINOR_SIGHT_MOD');

INSERT INTO	Modifiers
		(ModifierId,							ModifierType,								SubjectRequirementSetId)
VALUES	('SAILOR_WATCHTOWER_MAJOR_SIGHT_MOD',	'MODIFIER_SAILOR_WATCHTOWER_SIGHT_ADJUST',	'SAILOR_WATCHTOWER_PLOT_REQUIREMENT'),
		('SAILOR_WATCHTOWER_MINOR_SIGHT_MOD',	'MODIFIER_SAILOR_WATCHTOWER_SIGHT_ADJUST',	'SAILOR_WATCHTOWER_ADJ_BUFF_REQUIREMENT');

INSERT INTO	ModifierArguments
		(ModifierId,							Name,		Value)
VALUES	('SAILOR_WATCHTOWER_MAJOR_SIGHT_MOD',	'Amount',	2),
		('SAILOR_WATCHTOWER_MINOR_SIGHT_MOD',	'Amount',	1);
-----------------------------------------------	
-- RequirementSets
-----------------------------------------------
INSERT INTO RequirementSets
		(RequirementSetId,							RequirementSetType)
VALUES	-- Umbrella requirementset that checks for unit on watchtower or unit on
		-- defensive plot with watchtower adjacent.
		('SAILOR_WATCHTOWER_UMBRELLA_REQUIREMENT',	'REQUIREMENTSET_TEST_ANY'),
			-- Checks plot for watchtower.
			('SAILOR_WATCHTOWER_PLOT_REQUIREMENT',		'REQUIREMENTSET_TEST_ALL'),
			-- Checks plot for defensive item with watchtower adjacent.
			('SAILOR_WATCHTOWER_ADJ_BUFF_REQUIREMENT',	'REQUIREMENTSET_TEST_ALL'),
				-- Requirementset to iterate defensive items.
				('SAILOR_WATCHTOWER_ADJ_DEF_REQUIREMENT',	'REQUIREMENTSET_TEST_ANY');
-----------------------------------------------
-- RequirementSetRequirements
-----------------------------------------------
INSERT INTO RequirementSetRequirements	
		(RequirementSetId,							RequirementId)
VALUES	('SAILOR_WATCHTOWER_UMBRELLA_REQUIREMENT',	'SAILOR_WT_REQUIRES_ON_WATCHTOWER_REQSET_MET'),
		('SAILOR_WATCHTOWER_UMBRELLA_REQUIREMENT',	'SAILOR_WT_REQUIRES_ADJ_WATCHTOWER_REQSET_MET'),

		('SAILOR_WATCHTOWER_PLOT_REQUIREMENT',		'SAILOR_WT_REQUIRES_WATCHTOWER_ON_PLOT'),

		('SAILOR_WATCHTOWER_ADJ_BUFF_REQUIREMENT',	'SAILOR_WT_REQUIRES_WATCHTOWER_ADJ'),
		('SAILOR_WATCHTOWER_ADJ_BUFF_REQUIREMENT',	'SAILOR_WT_REQUIRES_PLOT_IS_DEFENSIVE');

INSERT INTO RequirementSetRequirements
		(RequirementSetId,							RequirementId)
SELECT	'SAILOR_WATCHTOWER_ADJ_DEF_REQUIREMENT',	'SAILOR_WT_REQUIRES_PLOT_'||DistrictType
FROM Districts WHERE DistrictType = 'DISTRICT_ENCAMPMENT' OR DistrictType IN (SELECT CivUniqueDistrictType FROM DistrictReplaces WHERE ReplacesDistrictType = 'DISTRICT_ENCAMPMENT');

INSERT INTO RequirementSetRequirements
		(RequirementSetId,							RequirementId)
SELECT	'SAILOR_WATCHTOWER_ADJ_DEF_REQUIREMENT',	'SAILOR_WT_REQUIRES_PLOT_'||ImprovementType
FROM Improvements WHERE DefenseModifier > 0;
-----------------------------------------------
-- Requirements
-----------------------------------------------
INSERT INTO Requirements
		(RequirementId,										RequirementType)
VALUES	('SAILOR_WT_REQUIRES_ON_WATCHTOWER_REQSET_MET',		'REQUIREMENT_REQUIREMENTSET_IS_MET'),
		('SAILOR_WT_REQUIRES_ADJ_WATCHTOWER_REQSET_MET',	'REQUIREMENT_REQUIREMENTSET_IS_MET'),

		('SAILOR_WT_REQUIRES_WATCHTOWER_ON_PLOT',			'REQUIREMENT_PLOT_IMPROVEMENT_TYPE_MATCHES'),
		
		('SAILOR_WT_REQUIRES_WATCHTOWER_ADJ',				'REQUIREMENT_PLOT_ADJACENT_IMPROVEMENT_TYPE_MATCHES'),
		('SAILOR_WT_REQUIRES_PLOT_IS_DEFENSIVE',			'REQUIREMENT_REQUIREMENTSET_IS_MET');

INSERT INTO Requirements
		(RequirementId,									RequirementType)
SELECT	'SAILOR_WT_REQUIRES_PLOT_'||DistrictType,		'REQUIREMENT_PLOT_DISTRICT_TYPE_MATCHES'
FROM Districts WHERE DistrictType = 'DISTRICT_ENCAMPMENT' OR DistrictType IN (SELECT CivUniqueDistrictType FROM DistrictReplaces WHERE ReplacesDistrictType = 'DISTRICT_ENCAMPMENT');

INSERT INTO Requirements
		(RequirementId,									RequirementType)
SELECT	'SAILOR_WT_REQUIRES_PLOT_'||ImprovementType,	'REQUIREMENT_PLOT_IMPROVEMENT_TYPE_MATCHES'
FROM Improvements WHERE DefenseModifier > 0;
-----------------------------------------------
-- RequirementArguments
-----------------------------------------------
INSERT INTO RequirementArguments
		(RequirementId,										Name,				Value)
VALUES	('SAILOR_WT_REQUIRES_ON_WATCHTOWER_REQSET_MET',		'RequirementSetId',	'SAILOR_WATCHTOWER_PLOT_REQUIREMENT'),
		('SAILOR_WT_REQUIRES_ADJ_WATCHTOWER_REQSET_MET',	'RequirementSetId',	'SAILOR_WATCHTOWER_ADJ_BUFF_REQUIREMENT'),

		('SAILOR_WT_REQUIRES_WATCHTOWER_ON_PLOT',			'ImprovementType',	'IMPROVEMENT_SAILOR_WATCHTOWER'),
		
		('SAILOR_WT_REQUIRES_WATCHTOWER_ADJ',				'ImprovementType',	'IMPROVEMENT_SAILOR_WATCHTOWER'),
		('SAILOR_WT_REQUIRES_PLOT_IS_DEFENSIVE',			'RequirementSetId',	'SAILOR_WATCHTOWER_ADJ_DEF_REQUIREMENT');

INSERT INTO RequirementArguments
		(RequirementId,									Name,				Value)
SELECT	'SAILOR_WT_REQUIRES_PLOT_'||DistrictType,		'DistrictType',		DistrictType
FROM Districts WHERE DistrictType = 'DISTRICT_ENCAMPMENT' OR DistrictType IN (SELECT CivUniqueDistrictType FROM DistrictReplaces WHERE ReplacesDistrictType = 'DISTRICT_ENCAMPMENT');

INSERT INTO RequirementArguments
		(RequirementId,									Name,				Value)
SELECT	'SAILOR_WT_REQUIRES_PLOT_'||ImprovementType,	'ImprovementType',	ImprovementType
FROM Improvements WHERE DefenseModifier > 0;