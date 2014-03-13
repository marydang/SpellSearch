-- Set up the unit test environment for addon code.
-- This file should be included in all unit tests.
-- NOTE: Assumes the test is being run in the the test directory.

--
-- Set Path and Load Modules
--

-- Get current working directory for require path (from lua-users.org)
function getcwd()
   local file = arg[0]
   local path = string.gsub(file, "^(.*)[\\\/]?test[\\\/][^\\\/]+$", "%1");
   print(path)
   --if path == '' then
   --   path = '.'
   --end
   return path
end

-- Set the path
cwd = getcwd()
print(cwd)

-- Load unit test library
package.path = ";?.lua;../?.lua;../lib/?.lua;../lib/FitzUtils/?.lua;lib/FitzUtils/?.lua;" .. package.path
require('test/luaunit/luaunit')

-- Load up modules for testing.
require("Util")
require("TestUtil")
require("ApiEmulation")

-- Init from the toc file.
LoadForUnitTest("SpellSearch.toc")

