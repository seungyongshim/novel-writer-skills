import fs from 'fs-extra';
import path from 'path';

export interface ProjectInfo {
  name: string;
  version: string;
  hasClaudeDir: boolean;
  hasSpecifyDir: boolean;
  hasStoriesDir: boolean;
}

/**
 * 현재 디렉토리가 novel-writer-skills 프로젝트인지 감지
 */
export async function isProjectRoot(dir: string): Promise<boolean> {
  const configPath = path.join(dir, '.specify', 'config.json');
  return await fs.pathExists(configPath);
}

/**
 * 상위 디렉토리로 프로젝트 루트 검색
 */
export async function findProjectRoot(startDir: string = process.cwd()): Promise<string | null> {
  let currentDir = startDir;
  
  while (true) {
    if (await isProjectRoot(currentDir)) {
      return currentDir;
    }
    
    const parentDir = path.dirname(currentDir);
    
    // 파일 시스템 루트에 도달
    if (parentDir === currentDir) {
      return null;
    }
    
    currentDir = parentDir;
  }
}

/**
 * 프로젝트 루트에 있는지 확인, 아니면 오류 발생
 */
export async function ensureProjectRoot(): Promise<string> {
  const projectRoot = await findProjectRoot();
  
  if (!projectRoot) {
    throw new Error('NOT_IN_PROJECT');
  }
  
  return projectRoot;
}

/**
 * 프로젝트 정보 가져오기
 */
export async function getProjectInfo(projectPath: string): Promise<ProjectInfo | null> {
  try {
    const configPath = path.join(projectPath, '.specify', 'config.json');
    
    if (!await fs.pathExists(configPath)) {
      return null;
    }
    
    const config = await fs.readJson(configPath);
    
    return {
      name: config.name || path.basename(projectPath),
      version: config.version || 'unknown',
      hasClaudeDir: await fs.pathExists(path.join(projectPath, '.claude')),
      hasSpecifyDir: await fs.pathExists(path.join(projectPath, '.specify')),
      hasStoriesDir: await fs.pathExists(path.join(projectPath, 'stories'))
    };
  } catch {
    return null;
  }
}

