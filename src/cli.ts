#!/usr/bin/env node

import { Command } from '@commander-js/extra-typings';
import chalk from 'chalk';
import path from 'path';
import fs from 'fs-extra';
import ora from 'ora';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';
import { getVersion, getVersionInfo } from './version.js';
import { PluginManager } from './plugins/manager.js';
import { ensureProjectRoot, getProjectInfo } from './utils/project.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const program = new Command();

// 환영 배너 표시
function displayBanner(): void {
  const banner = `
╔═══════════════════════════════════════╗
║  📚  Novel Writer Skills  📝          ║
║  Claude Code 전용 소설 창작 도구     ║
╚═══════════════════════════════════════╝
`;
  console.log(chalk.cyan(banner));
  console.log(chalk.gray(`  ${getVersionInfo()}\n`));
}

displayBanner();

program
  .name('novelwrite')
  .description(chalk.cyan('Novel Writer Skills - Claude Code 전용 소설 창작 도구'))
  .version(getVersion(), '-v, --version', '버전 번호 표시')
  .helpOption('-h, --help', '도움말 표시');

// init 명령 - 소설 프로젝트 초기화
program
  .command('init')
  .argument('[name]', '소설 프로젝트 이름')
  .option('--here', '현재 디렉토리에서 초기화')
  .option('--plugins <names>', '사전 설치 플러그인, 쉼표 구분')
  .option('--no-git', 'Git 초기화 건너뛰기')
  .description('새 소설 프로젝트 초기화')
  .action(async (name, options) => {
    const spinner = ora('소설 프로젝트 초기화 중...').start();

    try {
      // 프로젝트 경로 결정
      let projectPath: string;
      if (options.here) {
        projectPath = process.cwd();
        name = path.basename(projectPath);
      } else {
        if (!name) {
          spinner.fail('프로젝트 이름을 제공하거나 --here 옵션을 사용하세요');
          process.exit(1);
        }
        projectPath = path.join(process.cwd(), name);
        if (await fs.pathExists(projectPath)) {
          spinner.fail(`프로젝트 디렉토리 "${name}"가 이미 존재합니다`);
          process.exit(1);
        }
        await fs.ensureDir(projectPath);
      }

      // 기본 프로젝트 구조 생성
      const baseDirs = [
        '.specify',
        '.specify/memory',
        '.specify/templates',
        '.claude',
        '.claude/commands',
        '.claude/skills',
        'stories',
        'spec',
        'spec/tracking',
        'spec/knowledge'
      ];

      for (const dir of baseDirs) {
        await fs.ensureDir(path.join(projectPath, dir));
      }

      // 기본 설정 파일 생성
      const config = {
        name,
        type: 'novel',
        ai: 'claude',
        created: new Date().toISOString(),
        version: getVersion()
      };

      await fs.writeJson(path.join(projectPath, '.specify', 'config.json'), config, { spaces: 2 });

      // novel-writer-skills 패키지에서 템플릿 파일 복사
      const packageRoot = path.resolve(__dirname, '..');

      // 명령 파일 복사
      const commandsSource = path.join(packageRoot, 'templates', 'commands');
      const commandsDest = path.join(projectPath, '.claude', 'commands');
      if (await fs.pathExists(commandsSource)) {
        await fs.copy(commandsSource, commandsDest);
        spinner.text = 'Slash Commands 설치 완료...';
      }

      // Skills 파일 복사
      const skillsSource = path.join(packageRoot, 'templates', 'skills');
      const skillsDest = path.join(projectPath, '.claude', 'skills');
      if (await fs.pathExists(skillsSource)) {
        await fs.copy(skillsSource, skillsDest);
        spinner.text = 'Agent Skills 설치 완료...';
      }

      // .specify/templates에 템플릿 파일 복사
      const fullTemplatesDir = path.join(packageRoot, 'templates');
      if (await fs.pathExists(fullTemplatesDir)) {
        const userTemplatesDir = path.join(projectPath, '.specify', 'templates');
        await fs.copy(fullTemplatesDir, userTemplatesDir, { overwrite: false });
      }

      // memory 파일 복사
      const memoryDir = path.join(packageRoot, 'templates', 'memory');
      if (await fs.pathExists(memoryDir)) {
        const userMemoryDir = path.join(projectPath, '.specify', 'memory');
        await fs.copy(memoryDir, userMemoryDir);
      }

      // 추적 파일 템플릿 복사
      const trackingTemplatesDir = path.join(packageRoot, 'templates', 'tracking');
      if (await fs.pathExists(trackingTemplatesDir)) {
        const userTrackingDir = path.join(projectPath, 'spec', 'tracking');
        await fs.copy(trackingTemplatesDir, userTrackingDir);
      }

      // 지식 라이브러리 템플릿 복사 (프로젝트 전용)
      const knowledgeTemplatesDir = path.join(packageRoot, 'templates', 'knowledge');
      if (await fs.pathExists(knowledgeTemplatesDir)) {
        const userKnowledgeDir = path.join(projectPath, 'spec', 'knowledge');
        await fs.copy(knowledgeTemplatesDir, userKnowledgeDir);
      }

      // 범용 지식 라이브러리 시스템 복사 (v1.0 추가)
      const knowledgeBaseDir = path.join(packageRoot, 'templates', 'knowledge-base');
      if (await fs.pathExists(knowledgeBaseDir)) {
        const claudeKnowledgeBaseDir = path.join(projectPath, '.claude', 'knowledge-base');
        await fs.copy(knowledgeBaseDir, claudeKnowledgeBaseDir);
        spinner.text = '지식 라이브러리 시스템 설치 완료...';
      }

      // --plugins 옵션이 지정된 경우 플러그인 설치
      if (options.plugins) {
        spinner.text = '플러그인 설치 중...';
        const pluginNames = options.plugins.split(',').map((p: string) => p.trim());
        const pluginManager = new PluginManager(projectPath);

        for (const pluginName of pluginNames) {
          const builtinPluginPath = path.join(packageRoot, 'plugins', pluginName);
          if (await fs.pathExists(builtinPluginPath)) {
            await pluginManager.installPlugin(pluginName, builtinPluginPath);
          } else {
            console.log(chalk.yellow(`\n경고: 플러그인 "${pluginName}"을 찾을 수 없습니다`));
          }
        }
      }

      // Git 초기화
      if (options.git !== false) {
        try {
          execSync('git init', { cwd: projectPath, stdio: 'ignore' });

          const gitignore = `# 임시 파일
*.tmp
*.swp
.DS_Store

# 에디터 설정
.vscode/
.idea/

# AI 캐시
.ai-cache/

# 노드 모듈
node_modules/
`;
          await fs.writeFile(path.join(projectPath, '.gitignore'), gitignore);
          execSync('git add .', { cwd: projectPath, stdio: 'ignore' });
          execSync('git commit -m "소설 프로젝트 초기화"', { cwd: projectPath, stdio: 'ignore' });
        } catch {
          console.log(chalk.yellow('\n안내: Git 초기화 실패했지만 프로젝트는 성공적으로 생성되었습니다'));
        }
      }

      spinner.succeed(chalk.green(`소설 프로젝트 "${name}" 생성 완료!`));

      // 후속 단계 표시
      console.log('\n' + chalk.cyan('다음 단계:'));
      console.log(chalk.gray('─────────────────────────────'));

      if (!options.here) {
        console.log(`  1. ${chalk.white(`cd ${name}`)} - 프로젝트 디렉토리로 이동`);
      }

      console.log(`  2. ${chalk.white('Claude Code에서 프로젝트 열기')}`);
      console.log(`  3. 아래 슬래시 명령으로 창작 시작:`);

      console.log('\n' + chalk.yellow('     📝 7단계 방법론:'));
      console.log(`     ${chalk.cyan('/constitution')} - 창작 헌법 생성, 핵심 원칙 정의`);
      console.log(`     ${chalk.cyan('/specify')}      - 스토리 사양 정의, 무엇을 만들지 명확화`);
      console.log(`     ${chalk.cyan('/clarify')}      - 핵심 결정 사항 명확화, 모호한 부분 해소`);
      console.log(`     ${chalk.cyan('/plan')}         - 기술 방안 수립, 어떻게 창작할지 결정`);
      console.log(`     ${chalk.cyan('/tasks')}        - 실행 작업 분해, 실행 가능한 체크리스트 생성`);
      console.log(`     ${chalk.cyan('/write')}        - AI 보조 집필 챕터 내용`);
      console.log(`     ${chalk.cyan('/analyze')}      - 종합 검증 분석, 품질 일관성 확보`);

      console.log('\n' + chalk.yellow('     📊 추적 관리 명령:'));
      console.log(`     ${chalk.cyan('/track-init')}  - 추적 시스템 초기화`);
      console.log(`     ${chalk.cyan('/track')}       - 종합 추적 업데이트`);
      console.log(`     ${chalk.cyan('/plot-check')}  - 플롯 일관성 검사`);
      console.log(`     ${chalk.cyan('/timeline')}    - 스토리 타임라인 관리`);

      console.log('\n' + chalk.gray('Agent Skills는 자동 활성화되며 수동 호출이 필요 없습니다'));
      console.log(chalk.dim('팁: 슬래시 명령은 Claude Code 내부에서 사용하며 터미널에서 사용하는 것이 아닙니다'));

    } catch (error) {
      spinner.fail(chalk.red('프로젝트 초기화 실패'));
      console.error(error);
      process.exit(1);
    }
  });

// check 명령 - 환경 확인
program
  .command('check')
  .description('시스템 환경 및 Claude Code 확인')
  .action(() => {
    console.log(chalk.cyan('시스템 환경 확인 중...\n'));

    const checks = [
      { name: 'Node.js', command: 'node --version', installed: false },
      { name: 'Git', command: 'git --version', installed: false }
    ];

    checks.forEach(check => {
      try {
        const version = execSync(check.command, { encoding: 'utf-8' }).trim();
        check.installed = true;
        console.log(chalk.green('✓') + ` ${check.name} 설치됨 (${version})`);
      } catch {
        console.log(chalk.yellow('⚠') + ` ${check.name} 미설치`);
      }
    });

    console.log('\n' + chalk.cyan('Claude Code 감지:'));
    console.log(chalk.gray('Claude Code가 설치되어 있고 정상적으로 사용 가능한지 확인하세요'));
    console.log(chalk.gray('다운로드: https://claude.ai/download'));

    console.log('\n' + chalk.green('환경 확인 완료!'));
  });

// plugin 명령 - 플러그인 관리
program
  .command('plugin')
  .description('플러그인 관리 (plugin:list, plugin:add, plugin:remove 사용)')
  .action(() => {
    console.log(chalk.cyan('\n📦 플러그인 관리 명령:\n'));
    console.log('  novelwrite plugin:list              - 설치된 플러그인 목록');
    console.log('  novelwrite plugin:add <name>        - 플러그인 설치');
    console.log('  novelwrite plugin:remove <name>     - 플러그인 제거');
    console.log('\n' + chalk.gray('사용 가능한 플러그인:'));
    console.log('  authentic-voice   - 진정성 있는 음성 집필 플러그인');
  });

program
  .command('plugin:list')
  .description('설치된 플러그인 목록')
  .action(async () => {
    try {
      const projectPath = await ensureProjectRoot();
      const projectInfo = await getProjectInfo(projectPath);

      if (!projectInfo) {
        console.log(chalk.red('❌ 프로젝트 정보를 읽을 수 없습니다'));
        process.exit(1);
      }

      const pluginManager = new PluginManager(projectPath);
      const plugins = await pluginManager.listPlugins();

      console.log(chalk.cyan('\n📦 설치된 플러그인\n'));
      console.log(chalk.gray(`프로젝트: ${path.basename(projectPath)}\n`));

      if (plugins.length === 0) {
        console.log(chalk.yellow('플러그인 없음'));
        console.log(chalk.gray('\n"novel-skills plugin:add <name>" 으로 플러그인을 설치하세요'));
        console.log(chalk.gray('사용 가능한 플러그인: authentic-voice\n'));
        return;
      }

      for (const plugin of plugins) {
        console.log(chalk.yellow(`  ${plugin.name}`) + ` (v${plugin.version})`);
        console.log(chalk.gray(`    ${plugin.description}`));

        if (plugin.commands && plugin.commands.length > 0) {
          console.log(chalk.gray(`    명령: ${plugin.commands.map(c => `/${c.id}`).join(', ')}`));
        }

        if (plugin.skills && plugin.skills.length > 0) {
          console.log(chalk.gray(`    Skills: ${plugin.skills.map(s => s.id).join(', ')}`));
        }
        console.log('');
      }
    } catch (error: any) {
      if (error.message === 'NOT_IN_PROJECT') {
        console.log(chalk.red('\n❌ 현재 디렉토리는 novelwrite 프로젝트가 아닙니다'));
        console.log(chalk.gray('   프로젝트 루트 디렉토리에서 이 명령을 실행하세요\n'));
        process.exit(1);
      }

      console.error(chalk.red('❌ 플러그인 목록 조회 실패:'), error);
      process.exit(1);
    }
  });

program
  .command('plugin:add <name>')
  .description('플러그인 설치')
  .action(async (name) => {
    try {
      const projectPath = await ensureProjectRoot();
      const projectInfo = await getProjectInfo(projectPath);

      if (!projectInfo) {
        console.log(chalk.red('❌ 프로젝트 정보를 읽을 수 없습니다'));
        process.exit(1);
      }

      console.log(chalk.cyan('\n📦 NovelWrite 플러그인 설치\n'));
      console.log(chalk.gray(`프로젝트 버전: ${projectInfo.version}\n`));

      const packageRoot = path.resolve(__dirname, '..');
      const builtinPluginPath = path.join(packageRoot, 'plugins', name);

      if (!await fs.pathExists(builtinPluginPath)) {
        console.log(chalk.red(`❌ 플러그인 ${name}을 찾을 수 없습니다\n`));
        console.log(chalk.gray('사용 가능한 플러그인:'));
        console.log(chalk.gray('  - authentic-voice (진정성 있는 음성 플러그인)'));
        process.exit(1);
      }

      const spinner = ora('플러그인 설치 중...').start();
      const pluginManager = new PluginManager(projectPath);

      await pluginManager.installPlugin(name, builtinPluginPath);
      spinner.succeed(chalk.green('플러그인 설치 성공!\n'));

    } catch (error: any) {
      if (error.message === 'NOT_IN_PROJECT') {
        console.log(chalk.red('\n❌ 현재 디렉토리는 novelwrite 프로젝트가 아닙니다'));
        console.log(chalk.gray('   프로젝트 루트 디렉토리에서 이 명령을 실행하세요\n'));
        process.exit(1);
      }

      console.log(chalk.red('\n❌ 플러그인 설치 실패'));
      console.error(chalk.gray(error.message || error));
      console.log('');
      process.exit(1);
    }
  });

program
  .command('plugin:remove <name>')
  .description('플러그인 제거')
  .action(async (name) => {
    try {
      const projectPath = await ensureProjectRoot();
      const pluginManager = new PluginManager(projectPath);

      console.log(chalk.cyan('\n📦 NovelWrite 플러그인 제거\n'));
      console.log(chalk.gray(`제거할 플러그인: ${name}\n`));

      const spinner = ora('플러그인 제거 중...').start();
      await pluginManager.removePlugin(name);
      spinner.succeed(chalk.green('플러그인 제거 성공!\n'));
    } catch (error: any) {
      if (error.message === 'NOT_IN_PROJECT') {
        console.log(chalk.red('\n❌ 현재 디렉토리는 novelwrite 프로젝트가 아닙니다'));
        console.log(chalk.gray('   프로젝트 루트 디렉토리에서 이 명령을 실행하세요\n'));
        process.exit(1);
      }

      console.log(chalk.red('\n❌ 플러그인 제거 실패'));
      console.error(chalk.gray(error.message || error));
      console.log('');
      process.exit(1);
    }
  });

// upgrade 명령 - 기존 프로젝트 업그레이드
program
  .command('upgrade')
  .option('--commands', '명령 파일 업데이트')
  .option('--skills', 'Skills 파일 업데이트')
  .option('--knowledge-base', '지식 라이브러리 시스템 업데이트')
  .option('--all', '모든 콘텐츠 업데이트')
  .option('-y, --yes', '확인 프롬프트 건너뛰기')
  .description('기존 프로젝트를 최신 버전으로 업그레이드')
  .action(async (options) => {
    const projectPath = process.cwd();
    const packageRoot = path.resolve(__dirname, '..');

    try {
      const configPath = path.join(projectPath, '.specify', 'config.json');
      if (!await fs.pathExists(configPath)) {
        console.log(chalk.red('❌ 현재 디렉토리는 novel-writer-skills 프로젝트가 아닙니다'));
        process.exit(1);
      }

      const config = await fs.readJson(configPath);
      const projectVersion = config.version || '알 수 없음';

      console.log(chalk.cyan('\n📦 NovelWrite 프로젝트 업그레이드\n'));
      console.log(chalk.gray(`현재 버전: ${projectVersion}`));
      console.log(chalk.gray(`목표 버전: ${getVersion()}\n`));

      let updateCommands = options.all || options.commands || false;
      let updateSkills = options.all || options.skills || false;
      let updateKnowledgeBase = options.all || options.knowledgeBase || false;

      if (!updateCommands && !updateSkills && !updateKnowledgeBase) {
        updateCommands = true;
        updateSkills = true;
        updateKnowledgeBase = true;
      }

      if (!options.yes) {
        const inquirer = (await import('inquirer')).default;
        const answers = await inquirer.prompt([
          {
            type: 'confirm',
            name: 'proceed',
            message: '업그레이드를 실행하시겠습니까?',
            default: true
          }
        ]);

        if (!answers.proceed) {
          console.log(chalk.yellow('\n업그레이드가 취소되었습니다'));
          process.exit(0);
        }
      }

      const spinner = ora('프로젝트 업그레이드 중...').start();

      if (updateCommands) {
        spinner.text = 'Slash Commands 업데이트 중...';
        const commandsSource = path.join(packageRoot, 'templates', 'commands');
        const commandsDest = path.join(projectPath, '.claude', 'commands');
        if (await fs.pathExists(commandsSource)) {
          await fs.copy(commandsSource, commandsDest, { overwrite: true });
        }
      }

      if (updateSkills) {
        spinner.text = 'Agent Skills 업데이트 중...';
        const skillsSource = path.join(packageRoot, 'templates', 'skills');
        const skillsDest = path.join(projectPath, '.claude', 'skills');
        if (await fs.pathExists(skillsSource)) {
          await fs.copy(skillsSource, skillsDest, { overwrite: true });
        }
      }

      if (updateKnowledgeBase) {
        spinner.text = '지식 라이브러리 시스템 업데이트 중...';
        const knowledgeBaseSource = path.join(packageRoot, 'templates', 'knowledge-base');
        const knowledgeBaseDest = path.join(projectPath, '.claude', 'knowledge-base');
        if (await fs.pathExists(knowledgeBaseSource)) {
          await fs.copy(knowledgeBaseSource, knowledgeBaseDest, { overwrite: true });
        }
      }

      config.version = getVersion();
      await fs.writeJson(configPath, config, { spaces: 2 });

      spinner.succeed(chalk.green('업그레이드 완료!\n'));

      console.log(chalk.cyan('✨ 업그레이드 내용:'));
      if (updateCommands) console.log('  • Slash Commands 업데이트 완료');
      if (updateSkills) console.log('  • Agent Skills 업데이트 완료');
      if (updateKnowledgeBase) console.log('  • 지식 라이브러리 시스템 업데이트 완료 (styles/ 및 requirements/ 포함)');
      console.log(`  • 버전: ${projectVersion} → ${getVersion()}`);

    } catch (error) {
      console.error(chalk.red('\n❌ 업그레이드 실패:'), error);
      process.exit(1);
    }
  });

// 사용자 정의 도움말
program.on('--help', () => {
  console.log('');
  console.log(chalk.yellow('사용 예시:'));
  console.log('');
  console.log('  $ novelwrite init my-story      # 새 프로젝트 생성');
  console.log('  $ novelwrite init --here        # 현재 디렉토리에서 초기화');
  console.log('  $ novelwrite check              # 환경 확인');
  console.log('  $ novelwrite plugin:list        # 플러그인 목록');
  console.log('');
  console.log(chalk.gray('더 많은 정보: https://github.com/wordflowlab/novel-writer-skills'));
});

// 명령줄 인수 파싱
program.parse(process.argv);

// 명령이 제공되지 않은 경우 도움말 표시
if (!process.argv.slice(2).length) {
  program.outputHelp();
}

