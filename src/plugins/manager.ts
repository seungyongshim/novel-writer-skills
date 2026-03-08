import fs from 'fs-extra';
import path from 'path';
import yaml from 'js-yaml';
import { logger } from '../utils/logger.js';

interface PluginConfig {
  name: string;
  version: string;
  description: string;
  type: 'feature' | 'expert' | 'workflow';
  commands?: Array<{
    id: string;
    file: string;
    description: string;
  }>;
  skills?: Array<{
    id: string;
    file: string;
    description: string;
  }>;
  dependencies?: {
    core: string;
  };
  installation?: {
    message?: string;
  };
}

export class PluginManager {
  private pluginsDir: string;
  private commandsDir: string;
  private skillsDir: string;

  constructor(projectRoot: string) {
    this.pluginsDir = path.join(projectRoot, 'plugins');
    this.commandsDir = path.join(projectRoot, '.claude', 'commands');
    this.skillsDir = path.join(projectRoot, '.claude', 'skills');
  }

  /**
   * 모든 플러그인 스캔 및 로드
   */
  async loadPlugins(): Promise<void> {
    try {
      await fs.ensureDir(this.pluginsDir);
      const plugins = await this.scanPlugins();

      if (plugins.length === 0) {
        logger.info('플러그인이 발견되지 않았습니다');
        return;
      }

      logger.info(`${plugins.length}개 플러그인 발견`);

      for (const pluginName of plugins) {
        await this.loadPlugin(pluginName);
      }

      logger.success('모든 플러그인 로드 완료');
    } catch (error) {
      logger.error('플러그인 로드 실패:', error);
    }
  }

  /**
   * 플러그인 디렉토리 스캔
   */
  private async scanPlugins(): Promise<string[]> {
    try {
      if (!await fs.pathExists(this.pluginsDir)) {
        return [];
      }

      const entries = await fs.readdir(this.pluginsDir, { withFileTypes: true });
      const plugins = [];

      for (const entry of entries) {
        if (entry.isDirectory()) {
          const configPath = path.join(this.pluginsDir, entry.name, 'config.yaml');
          if (await fs.pathExists(configPath)) {
            plugins.push(entry.name);
          }
        }
      }

      return plugins;
    } catch (error) {
      logger.error('플러그인 디렉토리 스캔 실패:', error);
      return [];
    }
  }

  /**
   * 단일 플러그인 로드
   */
  private async loadPlugin(pluginName: string): Promise<void> {
    try {
      logger.info(`플러그인 로드: ${pluginName}`);

      const configPath = path.join(this.pluginsDir, pluginName, 'config.yaml');
      const config = await this.loadConfig(configPath);

      if (!config) {
        logger.warn(`플러그인 ${pluginName} 설정이 유효하지 않습니다`);
        return;
      }

      // 명령 주입
      if (config.commands && config.commands.length > 0) {
        await this.injectCommands(pluginName, config.commands);
      }

      // Skills 주입
      if (config.skills && config.skills.length > 0) {
        await this.injectSkills(pluginName, config.skills);
      }

      logger.success(`플러그인 ${pluginName} 로드 성공`);

      if (config.installation?.message) {
        console.log(config.installation.message);
      }
    } catch (error) {
      logger.error(`플러그인 ${pluginName} 로드 실패:`, error);
    }
  }

  /**
   * 플러그인 설정 읽기
   */
  private async loadConfig(configPath: string): Promise<PluginConfig | null> {
    try {
      const content = await fs.readFile(configPath, 'utf-8');
      const config = yaml.load(content) as PluginConfig;

      if (!config.name || !config.version) {
        return null;
      }

      return config;
    } catch (error) {
      logger.error(`설정 파일 읽기 실패: ${configPath}`, error);
      return null;
    }
  }

  /**
   * 플러그인 명령 주입
   */
  private async injectCommands(
    pluginName: string,
    commands: PluginConfig['commands']
  ): Promise<void> {
    if (!commands) return;

    for (const cmd of commands) {
      try {
        const sourcePath = path.join(this.pluginsDir, pluginName, cmd.file);
        const destPath = path.join(this.commandsDir, `${cmd.id}.md`);

        await fs.ensureDir(this.commandsDir);
        await fs.copy(sourcePath, destPath);
        logger.debug(`명령 주입: /${cmd.id}`);
      } catch (error) {
        logger.error(`명령 ${cmd.id} 주입 실패:`, error);
      }
    }
  }

  /**
   * 플러그인 Skills 주입
   */
  private async injectSkills(
    pluginName: string,
    skills: PluginConfig['skills']
  ): Promise<void> {
    if (!skills) return;

    for (const skill of skills) {
      try {
        const sourcePath = path.join(this.pluginsDir, pluginName, skill.file);
        const destPath = path.join(this.skillsDir, pluginName, path.basename(skill.file));

        await fs.ensureDir(path.dirname(destPath));
        await fs.copy(sourcePath, destPath);
        logger.debug(`Skill 주입: ${skill.id}`);
      } catch (error) {
        logger.error(`Skill ${skill.id} 주입 실패:`, error);
      }
    }
  }

  /**
   * 설치된 모든 플러그인 목록
   */
  async listPlugins(): Promise<PluginConfig[]> {
    const plugins = await this.scanPlugins();
    const configs: PluginConfig[] = [];

    for (const pluginName of plugins) {
      const configPath = path.join(this.pluginsDir, pluginName, 'config.yaml');
      const config = await this.loadConfig(configPath);
      if (config) {
        configs.push(config);
      }
    }

    return configs;
  }

  /**
   * 플러그인 설치
   */
  async installPlugin(pluginName: string, source?: string): Promise<void> {
    try {
      logger.info(`플러그인 설치: ${pluginName}`);

      if (source) {
        const destPath = path.join(this.pluginsDir, pluginName);
        await fs.copy(source, destPath);
      } else {
        logger.warn('원격 설치 기능은 아직 구현되지 않았습니다');
        return;
      }

      await this.loadPlugin(pluginName);
      logger.success(`플러그인 ${pluginName} 설치 성공`);
    } catch (error) {
      logger.error(`플러그인 ${pluginName} 설치 실패:`, error);
      throw error;
    }
  }

  /**
   * 플러그인 제거
   */
  async removePlugin(pluginName: string): Promise<void> {
    try {
      logger.info(`플러그인 제거: ${pluginName}`);

      // 플러그인 디렉토리 삭제
      const pluginPath = path.join(this.pluginsDir, pluginName);
      await fs.remove(pluginPath);

      // 주입된 명령 삭제
      if (await fs.pathExists(this.commandsDir)) {
        const commandFiles = await fs.readdir(this.commandsDir);
        for (const file of commandFiles) {
          // 여기서는 간소화 처리, 실제로는 플러그인 설정을 읽어 삭제할 파일을 결정해야 함
          // 어떤 명령이 이 플러그인에 속하는지 알아야 하므로 임시 스킵
        }
      }

      // 주입된 Skills 삭제
      const pluginSkillsDir = path.join(this.skillsDir, pluginName);
      if (await fs.pathExists(pluginSkillsDir)) {
        await fs.remove(pluginSkillsDir);
      }

      logger.success(`플러그인 ${pluginName} 제거 성공`);
    } catch (error) {
      logger.error(`플러그인 ${pluginName} 제거 실패:`, error);
      throw error;
    }
  }
}

