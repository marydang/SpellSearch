--
-- Unit tests for the PrefixTable class.
-- Tests can be run by running this command:
--   ./run_tests.sh
--

require("test/TestBase")
require("lib/PrefixTable")
require("lib/FitzUtils/Util")

-- Upvalues
local _UTIL = FitzUtils


-- Vars for testing
local _VAL1 = { dogs = "dogs" }
local _VAL2 = { goats = "fuzzy" }

-- Tests for parsing in the SpellSearch addon
TestPrefixTable = {}

-- Create a new table, and verify it's empty.
function TestPrefixTable:test_NewEmptyTable()
   local new_table = PrefixTable:New()
   assertEquals(new_table:Size(), 0)
   assertEquals(new_table:Exists(""), false)
end


-- Verify that duplicates are not allowed in the table.
function TestPrefixTable:test_AddSinglePrefixExistsNoDups()
   local new_table = PrefixTable:New()
   local expected = {_VAL1, _VAL2 }
   new_table:Add("fear", _VAL1)
   new_table:Add("fear", _VAL1)
   new_table:Add("fear", _VAL2)
   assertEquals(new_table:Size(), 4)
   assertEquals(_UTIL:TableEqual(new_table:GetList("f"), expected), true)
   assertEquals(_UTIL:TableEqual(new_table:GetList("fe"), expected), true)
   assertEquals(_UTIL:TableEqual(new_table:GetList("fea"), expected), true)
   assertEquals(_UTIL:TableEqual(new_table:GetList("fear"), expected), true)
   assertEquals(new_table:Exists("dogs"), false)
   
end

-- Create a new table, add a single prefix string, verify that all
-- prefixes, starting with the first letter are in the table.
function TestPrefixTable:test_AddSinglePrefixExists()
   local new_table = PrefixTable:New()
   new_table:Add("fear", _VAL1)
   assertEquals(new_table:Size(), 4)
   assertEquals(new_table:Exists("f"), true)
   assertEquals(new_table:Exists("fe"), true)
   assertEquals(new_table:Exists("fea"), true)
   assertEquals(new_table:Exists("fear"), true)
   assertEquals(new_table:Exists("dogs"), false)
end

-- Create a new table, add multiple strings (that don't overlap),
-- and verify that they all exist.
function TestPrefixTable:test_AddMultiplePrefixExists()
   local new_table = PrefixTable:New()
   new_table:Add("Charge", _VAL1)
   new_table:Add("Fear", _VAL2)
   assertEquals(new_table:Exists("F"), true)
   assertEquals(new_table:Exists("Fe"), true)
   assertEquals(new_table:Exists("Fea"), true)
   assertEquals(new_table:Exists("Fear"), true)
   assertEquals(new_table:Exists("Charge"), true)
   assertEquals(new_table:Exists("Charg"), true)
   assertEquals(new_table:Exists("Char"), true)
   assertEquals(new_table:Exists("Cha"), true)
   assertEquals(new_table:Exists("Ch"), true)
   assertEquals(new_table:Exists("C"), true)
end

-- Create a new table, add a single prefix string, then check to see if
-- a non-existant prefix exists.
function TestPrefixTable:test_PrefixNoExist()
   local new_table = PrefixTable:New()
   new_table:Add("dogs", _VAL1)
   assertEquals(new_table:Exists("dogs"), true)
   assertEquals(new_table:Exists("yay"), false)
end

-- Create a table, add 2 prefix strings (each must share at least one
-- prefix), and check that the correct prefixes exist.
function TestPrefixTable:test_PrefixOverlap()
   local new_table = PrefixTable:New()
   new_table:Add("Apples", _VAL1)
   new_table:Add("Ant", _VAL2)
   assertEquals(new_table:Size(), 8);
   assertEquals(new_table:Exists("A"), true)
end

-- Create a table, add a prefix, and then retrieve its list value.  Then
-- assure that the contents of that table remain unchanged when the result
-- list's contents are modified.
function TestPrefixTable:test_GetExistingList()
   local new_table = PrefixTable:New()
   new_table:Add("a", _VAL1)
   local result_list = new_table:GetList("a")
   assertEquals(_UTIL:NumElements(result_list), 1)
   assertEquals(_UTIL:TableEqual(result_list[1], _VAL1), true)
   table.insert(result_list, _VAL2)
   assertEquals(_UTIL:NumElements(result_list), 2)
   assertEquals(_UTIL:TableEqual(result_list[2], _VAL2), true)
   local result_list_orig = new_table:GetList("a")
   assertEquals(_UTIL:NumElements(result_list_orig), 1)
   assertEquals(_UTIL:TableEqual(result_list_orig[1], _VAL1), true)
end

-- Create a table, then attempt retrieve a list value (w/o adding anything).
function TestPrefixTable:test_GetNonexistList()
   local new_table = PrefixTable:New()
   local result_list = new_table:GetList("Shad")
   assertEquals(result_list, nil)
end

-- Create a table, add two prefixes (that share a common prefix), and then
-- retrieve that common prefix's list value.
function TestPrefixTable:test_GetCommonPrefixList()
   local new_table = PrefixTable:New()
   new_table:Add("Curse of Elements", _VAL1)
   new_table:Add("Curse of Weakness", _VAL2)
   local result_list = new_table:GetList("Curse of ")
   assertEquals(_UTIL:NumElements(result_list), 2)
   assertEquals(_UTIL:TableEqual(result_list[1], _VAL1), true)
   assertEquals(_UTIL:TableEqual(result_list[2], _VAL2), true)
end

-- Create a table, then clear it.
function TestPrefixTable:test_ClearEmptyPrefixList()
   local new_table = PrefixTable:New()
   new_table:Clear()
   assertEquals(new_table:Size(), 0)
end

-- Create a table, add a prefix, then clear it.
function TestPrefixTable:test_ClearPrefixList()
   local new_table = PrefixTable:New()
   new_table:Add("Curse of Elements", _VAL1)
   new_table:Clear()
   assertEquals(new_table:Size(), 0)
end

-- Create a table, add a prefix, clear it, then try adding another prefix.
function TestPrefixTable:test_ClearAddPrefixList()
   local new_table = PrefixTable:New()
   new_table:Add("Curse of Elements", _VAL1)
   new_table:Clear()
   assertEquals(new_table:Size(), 0)
   new_table:Add("Curse of Weakness", _VAL1)
   assertEquals(new_table:Size(), 17)
end

-- Create a table, add "Add" (same name as PrefixTable:Add()), and make
-- sure it doesn't weird out.
function TestPrefixTable:test_AddMethodCollision()
   local new_table = PrefixTable:New()
   new_table:Add("Add", _VAL1)
   assertEquals(new_table:Size(), 3)
end

-- Create a table, add a prefix in proper form, then in lowercase.  Ensure
-- that these are treated as separate and different keys.
function TestPrefixTable:test_MixedCase()
   local new_table = PrefixTable:New()
   new_table:Add("Charge", _VAL1)
   new_table:Add("charge", _VAL2)
   assertEquals(new_table:Size(), 12)
   local result_list1 = new_table:GetList("C")
   assertEquals(_UTIL:NumElements(result_list1), 1)
   assertEquals(_UTIL:TableEqual(result_list1[1], _VAL1), true)
   local result_list2 = new_table:GetList("c")
   assertEquals(_UTIL:NumElements(result_list2), 1)
   assertEquals(_UTIL:TableEqual(result_list2[1], _VAL2), true)
end

-- Create a table, add a prefix, then add another prefix that is a copy of the
-- first, but with a space and more characters.  Ensure that spaces are treated
-- as unique characters.
function TestPrefixTable:test_Spaces()
   local new_table = PrefixTable:New()
   new_table:Add("Battle", _VAL1)
   new_table:Add("Battle Stance", _VAL2)
   assertEquals(new_table:Size(), 13)
   assertEquals(new_table:Exists("Battle"), true)
   assertEquals(new_table:Exists("Battle "), true)
   assertEquals(new_table:Exists("Battle S"), true)
   local result_list1 = new_table:GetList("Battle")
   assertEquals(_UTIL:NumElements(result_list1), 2)
   assertEquals(_UTIL:TableEqual(result_list1[1], _VAL1), true)
   assertEquals(_UTIL:TableEqual(result_list1[2], _VAL2), true)
   local result_list2 = new_table:GetList("Battle ")
   assertEquals(_UTIL:NumElements(result_list2), 1)
   assertEquals(_UTIL:TableEqual(result_list2[1], _VAL2), true)
end

-- Run all tests unless overriden on the command line.
LuaUnit:run("TestPrefixTable")
