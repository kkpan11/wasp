module Wasp.Project.Common
  ( WaspProjectDir,
    DotWaspDir,
    NodeModulesDir,
    CompileError,
    CompileWarning,
    PackageJsonFile,
    SrcTsConfigFile,
    WaspFilePath (..),
    WaspLangFile,
    WaspTsFile,
    findFileInWaspProjectDir,
    dotWaspDirInWaspProjectDir,
    generatedCodeDirInDotWaspDir,
    buildDirInDotWaspDir,
    waspProjectDirFromProjectRootDir,
    dotWaspRootFileInWaspProjectDir,
    dotWaspInfoFileInGeneratedCodeDir,
    packageJsonInWaspProjectDir,
    packageLockJsonInWaspProjectDir,
    nodeModulesDirInWaspProjectDir,
    srcDirInWaspProjectDir,
    extPublicDirInWaspProjectDir,
    prismaSchemaFileInWaspProjectDir,
    getSrcTsConfigInWaspProjectDir,
    srcTsConfigInWaspLangProject,
    srcTsConfigInWaspTsProject,
    waspProjectDirFromAppComponentDir,
  )
where

import StrongPath (Abs, Dir, File, File', Path', Rel, reldir, relfile, toFilePath, (</>))
import System.Directory (doesFileExist)
import Wasp.AppSpec.ExternalFiles (SourceExternalCodeDir, SourceExternalPublicDir)
import qualified Wasp.Generator.Common as G.Common

type CompileError = String

type CompileWarning = String

data WaspProjectDir -- Root dir of Wasp project, containing source files.

data NodeModulesDir

data DotWaspDir -- Here we put everything that wasp generates.

data PackageJsonFile

data SrcTsConfigFile

data WaspFilePath
  = WaspLang !(Path' Abs (File WaspLangFile))
  | WaspTs !(Path' Abs (File WaspTsFile))

data WaspLangFile

data WaspTsFile

-- | NOTE: If you change the depth of this path, also update @waspProjectDirFromProjectRootDir@ below.
-- TODO: SHould this be renamed to include word "root"?
dotWaspDirInWaspProjectDir :: Path' (Rel WaspProjectDir) (Dir DotWaspDir)
dotWaspDirInWaspProjectDir = [reldir|.wasp|]

nodeModulesDirInWaspProjectDir :: Path' (Rel WaspProjectDir) (Dir NodeModulesDir)
nodeModulesDirInWaspProjectDir = [reldir|node_modules|]

-- | NOTE: If you change the depth of this path, also update @waspProjectDirFromProjectRootDir@ below.
generatedCodeDirInDotWaspDir :: Path' (Rel DotWaspDir) (Dir G.Common.ProjectRootDir)
-- TODO: We sometimes call this directory "ProjectRootDir" and sometimes
-- "GeneratedCodeDir". We should unify the naming (the latter is the beter
-- name).
generatedCodeDirInDotWaspDir = [reldir|out|]

-- | NOTE: If you change the depth of this path, also update @waspProjectDirFromProjectRootDir@ below.
buildDirInDotWaspDir :: Path' (Rel DotWaspDir) (Dir G.Common.ProjectRootDir)
buildDirInDotWaspDir = [reldir|build|]

-- TODO: This backwards relative path relies on multiple forward relative path
-- definitions. We should find a better way to express it (e.g., by somehow
-- calculating it from existing definitions)
waspProjectDirFromAppComponentDir :: G.Common.AppComponentRootDir d => Path' (Rel d) (Dir WaspProjectDir)
waspProjectDirFromAppComponentDir = [reldir|../../../|]

-- | NOTE: This path is calculated from the values of @dotWaspDirInWaspProjectDir@,
-- @generatedCodeDirInDotWaspDir@ and @buildDirInDotWaspDir@., which are the three functions just above.
-- Also, it assumes @generatedCodeDirInDotWaspDir@ and @buildDirInDotWaspDir@ have same depth.
-- If any of those change significantly (their depth), this path should be adjusted.
waspProjectDirFromProjectRootDir :: Path' (Rel G.Common.ProjectRootDir) (Dir WaspProjectDir)
waspProjectDirFromProjectRootDir = [reldir|../../|]

dotWaspRootFileInWaspProjectDir :: Path' (Rel WaspProjectDir) File'
dotWaspRootFileInWaspProjectDir = [relfile|.wasproot|]

dotWaspInfoFileInGeneratedCodeDir :: Path' (Rel G.Common.ProjectRootDir) File'
dotWaspInfoFileInGeneratedCodeDir = [relfile|.waspinfo|]

packageJsonInWaspProjectDir :: Path' (Rel WaspProjectDir) (File PackageJsonFile)
packageJsonInWaspProjectDir = [relfile|package.json|]

getSrcTsConfigInWaspProjectDir :: WaspFilePath -> Path' (Rel WaspProjectDir) (File SrcTsConfigFile)
getSrcTsConfigInWaspProjectDir = \case
  WaspTs _ -> srcTsConfigInWaspTsProject
  WaspLang _ -> srcTsConfigInWaspLangProject

srcTsConfigInWaspLangProject :: Path' (Rel WaspProjectDir) (File SrcTsConfigFile)
srcTsConfigInWaspLangProject = [relfile|tsconfig.json|]

srcTsConfigInWaspTsProject :: Path' (Rel WaspProjectDir) (File SrcTsConfigFile)
srcTsConfigInWaspTsProject = [relfile|tsconfig.src.json|]

packageLockJsonInWaspProjectDir :: Path' (Rel WaspProjectDir) File'
packageLockJsonInWaspProjectDir = [relfile|package-lock.json|]

prismaSchemaFileInWaspProjectDir :: Path' (Rel WaspProjectDir) File'
prismaSchemaFileInWaspProjectDir = [relfile|schema.prisma|]

srcDirInWaspProjectDir :: Path' (Rel WaspProjectDir) (Dir SourceExternalCodeDir)
srcDirInWaspProjectDir = [reldir|src|]

extPublicDirInWaspProjectDir :: Path' (Rel WaspProjectDir) (Dir SourceExternalPublicDir)
extPublicDirInWaspProjectDir = [reldir|public|]

findFileInWaspProjectDir ::
  Path' Abs (Dir WaspProjectDir) ->
  Path' (Rel WaspProjectDir) (File f) ->
  IO (Maybe (Path' Abs (File f)))
findFileInWaspProjectDir waspDir file = do
  let fileAbsFp = waspDir </> file
  fileExists <- doesFileExist $ toFilePath fileAbsFp
  return $ if fileExists then Just fileAbsFp else Nothing
