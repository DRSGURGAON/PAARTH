import '../models/quest.dart';

/// World 5 — Robot City quest content. Data only, no UI. Two quests
/// per location (the Mega Core's second quest is the final world boss),
/// Class 2 / age ~7 difficulty: addition and subtraction within 20,
/// simple patterns, picture words.
class RobotQuests {
  RobotQuests._();

  static const List<Quest> all = [
    // ── Robot Garage ───────────────────────────────────
    Quest(
      id: 'robot_tune_up',
      locationId: 'robot_garage',
      title: 'Robot Tune-Up',
      npc: QuestNpc(name: 'Bolt the Robo-Pup', emoji: '🤖'),
      storyIntro: 'Bolt the Robo-Pup squeaks when he walks! Help the '
          'garage find the right parts to fix him.',
      introDialogue: [
        'Beep beep! Squeak!',
        'Oh no — Bolt has a squeaky wheel!',
        'The garage needs a clever helper.',
        'Can you find the right parts, Super Kid?',
      ],
      storyOutro: 'Bolt zooms around in happy circles — no more squeaks! '
          'He is your robot friend forever now.',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the spare bolts!',
          visual: '🔩🔩🔩🔩🔩 🔩🔩🔩🔩🔩 🔩🔩',
          options: ['11', '12', '13'],
          correctIndex: 1,
          hint: 'Five, five, and two more!',
          rewardLabel: 'Bolt Box',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Bolt needs 15 screws. We have 8. How many more?',
          options: ['6', '7', '8'],
          correctIndex: 1,
          hint: 'Count up from 8 to 15!',
          rewardLabel: 'Screw Kit',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🤖',
          options: ['ROBOT', 'RABBIT', 'ROCKET'],
          correctIndex: 0,
          hint: 'It beeps and boops!',
          rewardLabel: 'Oil Can',
        ),
      ],
    ),
    Quest(
      id: 'wheel_workshop',
      locationId: 'robot_garage',
      title: 'The Wheel Workshop',
      storyIntro: 'The workshop is building wheels all day! Solve the '
          'wheel math to keep the machines rolling.',
      storyOutro: 'Round and round — every robot rolls out of the '
          'workshop on brand-new wheels!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Each robot needs 4 wheels. 2 robots wait. '
              'How many wheels?',
          visual: '🛞',
          options: ['6', '8', '10'],
          correctIndex: 1,
          hint: '4 wheels and 4 more wheels!',
          rewardLabel: 'Wheel Set',
        ),
        MathDashChallenge(
          prompt: 'The workshop screen flashes number puzzles! Solve '
              'them to power the wheel maker.',
          questionCount: 3,
          rewardLabel: 'Workshop Badge',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The belt goes: what comes next?',
          visual: '🛞 🔧 🛞 🔧 🛞 ❓',
          options: ['🔧', '🛞', '🔩'],
          correctIndex: 0,
          hint: 'Wheel, wrench, wheel, wrench...',
          rewardLabel: 'Lucky Wrench',
        ),
      ],
    ),

    // ── Energy Factory ─────────────────────────────────
    Quest(
      id: 'battery_charge',
      locationId: 'energy_factory',
      title: 'The Battery Charge',
      storyIntro: 'The city batteries are running low! Count and charge '
          'them before bedtime.',
      storyOutro: 'Every battery glows green and full. The whole city '
          'lights up to say thank you!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the batteries!',
          visual: '🔋🔋🔋🔋 🔋🔋🔋🔋 🔋🔋🔋🔋 🔋',
          options: ['12', '13', '14'],
          correctIndex: 1,
          hint: 'Four, four, four, and one more!',
          rewardLabel: 'Battery Rack',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '17 batteries. 8 are charged. How many still need '
              'charging?',
          options: ['8', '9', '10'],
          correctIndex: 1,
          hint: 'Take 8 away from 17!',
          rewardLabel: 'Charge Cable',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '💡',
          options: ['LIGHT', 'NIGHT', 'EIGHT'],
          correctIndex: 0,
          hint: 'You switch it on when it is dark!',
          rewardLabel: 'Glow Sticker',
        ),
      ],
    ),
    Quest(
      id: 'power_patterns',
      locationId: 'energy_factory',
      title: 'Power Patterns',
      storyIntro: 'The energy machine hums in patterns! Learn them to '
          'keep the power flowing.',
      storyOutro: 'The machine hums a perfect tune and the factory '
          'lights dance in rhythm!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The power flows: what comes next?',
          visual: '⚡ ⚡ 🔋 ⚡ ⚡ 🔋 ⚡ ⚡ ❓',
          options: ['🔋', '⚡', '💡'],
          correctIndex: 0,
          hint: 'Two zaps, one battery — again and again!',
          rewardLabel: 'Power Gauge',
        ),
        PatternPowerChallenge(
          prompt: 'The energy machine speaks in patterns! Discover '
              'them to keep the power flowing.',
          questionCount: 3,
          rewardLabel: 'Energy Core',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count by 10s: 10, 20, 30, … what comes next?',
          options: ['35', '40', '50'],
          correctIndex: 1,
          hint: 'Add 10 more to 30!',
          rewardLabel: 'Volt Medal',
        ),
      ],
    ),

    // ── Sky Bridge ─────────────────────────────────────
    Quest(
      id: 'sky_train_tickets',
      locationId: 'sky_bridge',
      title: 'Sky Train Tickets',
      storyIntro: 'The sky train is boarding! Help the conductor-bot '
          'count tickets and seats.',
      storyOutro: 'All aboard! The sky train glides over the city and '
          'the conductor-bot beeps a happy tune.',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the tickets!',
          visual: '🎫🎫🎫🎫🎫 🎫🎫🎫🎫🎫 🎫🎫🎫🎫',
          options: ['13', '14', '15'],
          correctIndex: 1,
          hint: 'Five, five, and four more!',
          rewardLabel: 'Ticket Punch',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'The train has 18 seats. 9 are taken. How many free?',
          options: ['8', '9', '10'],
          correctIndex: 1,
          hint: 'Take 9 away from 18!',
          rewardLabel: 'Window Seat',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🚄',
          options: ['TRAIN', 'RAIN', 'BRAIN'],
          correctIndex: 0,
          hint: 'It runs on rails — choo choo!',
          rewardLabel: 'Conductor Cap',
        ),
      ],
    ),
    Quest(
      id: 'cloud_counting',
      locationId: 'sky_bridge',
      title: 'Cloud Counting',
      storyIntro: 'From the sky bridge you can see everything! Count '
          'the clouds and solve the sky puzzles.',
      storyOutro: 'The clouds drift into a giant smiley face just for '
          'you. Best view in Robot City!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '7 clouds + 8 clouds. How many clouds?',
          visual: '☁️',
          options: ['14', '15', '16'],
          correctIndex: 1,
          hint: 'Start at 8 and count up 7 more!',
          rewardLabel: 'Cloud Chart',
        ),
        MathDashChallenge(
          prompt: 'The bridge computer shows sky number puzzles! Solve '
              'them to log every cloud.',
          questionCount: 3,
          rewardLabel: 'Sky Log',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The sky goes: what comes next?',
          visual: '☁️ 🐦 ☁️ 🐦 ☁️ ❓',
          options: ['🐦', '☁️', '⭐'],
          correctIndex: 0,
          hint: 'Cloud, bird, cloud, bird...',
          rewardLabel: 'Feather Pin',
        ),
      ],
    ),

    // ── Robot Lab ──────────────────────────────────────
    Quest(
      id: 'invention_time',
      locationId: 'robot_lab',
      title: 'Invention Time',
      storyIntro: 'The lab robots are inventing something amazing! '
          'Help them measure and count the parts.',
      storyOutro: 'TA-DA! The invention is a machine that makes '
          'ice cream. The lab celebrates with sprinkles!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the gears!',
          visual: '⚙️⚙️⚙️⚙️⚙️ ⚙️⚙️⚙️⚙️⚙️ ⚙️⚙️⚙️⚙️⚙️',
          options: ['14', '15', '16'],
          correctIndex: 1,
          hint: 'Five, five, and five — count by 5s!',
          rewardLabel: 'Gear Jar',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'The invention needs 20 springs. We have 13. '
              'How many more?',
          options: ['6', '7', '8'],
          correctIndex: 1,
          hint: 'Count up from 13 to 20!',
          rewardLabel: 'Spring Set',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🍦',
          options: ['ICE CREAM', 'ICE CUBE', 'I SCREAM'],
          correctIndex: 0,
          hint: 'Cold, sweet, and yummy in a cone!',
          rewardLabel: 'First Scoop',
        ),
      ],
    ),
    Quest(
      id: 'code_the_robot',
      locationId: 'robot_lab',
      title: 'Code the Robot',
      storyIntro: 'Teach the little lab robot to dance using pattern '
          'code! Robots learn everything by patterns.',
      storyOutro: 'The little robot does a perfect dance — then bows '
          'to its brilliant teacher: you!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The dance code goes: what comes next?',
          visual: '⬅️ ➡️ 🔄 ⬅️ ➡️ 🔄 ⬅️ ➡️ ❓',
          options: ['🔄', '⬅️', '➡️'],
          correctIndex: 0,
          hint: 'Left, right, spin — left, right, spin!',
          rewardLabel: 'Dance Code',
        ),
        PatternPowerChallenge(
          prompt: 'Robot code is made of patterns! Discover them to '
              'finish the dance program.',
          questionCount: 3,
          rewardLabel: 'Code Card',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'The dance has 12 steps + 7 more steps. How many?',
          options: ['18', '19', '20'],
          correctIndex: 1,
          hint: 'Start at 12 and count up 7 more!',
          rewardLabel: 'Teacher Star',
        ),
      ],
    ),

    // ── Mega Core ──────────────────────────────────────
    Quest(
      id: 'core_puzzles',
      locationId: 'mega_core',
      title: 'The Core Puzzles',
      storyIntro: 'The Mega Core protects all of Robot City! Solve its '
          'safety puzzles to reach the core room.',
      storyOutro: 'The core room doors slide open with a gentle hum. '
          'The great Mega Core glows ahead!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'What number comes next? 3, 6, 9, 12, …',
          options: ['13', '15', '18'],
          correctIndex: 1,
          hint: 'Add 3 more to 12!',
          rewardLabel: 'Core Pass 1',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🟩 🟩 🟦 🟩 🟩 🟦 🟩 🟩 ❓',
          options: ['🟦', '🟩', '🟥'],
          correctIndex: 0,
          hint: 'Two greens, one blue — again and again!',
          rewardLabel: 'Core Pass 2',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Which number is bigger?',
          options: ['19', '17'],
          correctIndex: 0,
          hint: 'Count up — which comes later?',
          rewardLabel: 'Core Pass 3',
        ),
      ],
    ),
    Quest(
      id: 'mega_core_awakens',
      locationId: 'mega_core',
      title: 'The Mega Core Awakens',
      npc: QuestNpc(name: 'Chief Gigabyte', emoji: '🦾'),
      storyIntro: 'Chief Gigabyte guards the Mega Core — the heart of '
          'Robot City and the final trial of your whole adventure!',
      introDialogue: [
        'SYSTEM ONLINE. Hello, Super Kid.',
        'I am Chief Gigabyte, keeper of the Mega Core.',
        'You have crossed jungles, space, dinos, and magic.',
        'Now face the final four trials!',
      ],
      storyOutro: 'The Mega Core shines like a sun! "ADVENTURE '
          'COMPLETE," beams Chief Gigabyte. "You are the greatest '
          'Super Kid of all five worlds!"',
      resolutionSteps: [
        '🦾 Chief Gigabyte scans your four trial keys...',
        '💠 The Mega Core wakes with a rainbow glow!',
        '🤖 Every robot in the city dances at once!',
        '🌍 All five worlds light up on the big screen!',
        '🏆 You are the Champion of every world, Super Kid!',
      ],
      starReward: 3,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Final Number Trial: 13 + 7. How many?',
          visual: '💠',
          options: ['19', '20', '21'],
          correctIndex: 1,
          hint: 'Start at 13 and count up 7 more!',
          rewardLabel: 'Number Key',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'Final Pattern Trial: what comes next?',
          visual: '🤖 💠 🤖 💠 💠 🤖 💠 💠 💠 🤖 ❓',
          options: ['💠', '🤖', '⚙️'],
          correctIndex: 0,
          hint: 'One core, two cores, three cores... then?',
          rewardLabel: 'Pattern Key',
        ),
        MemoryChallenge(
          prompt: 'Which helpers powered up the core?',
          itemsToRemember: '🤖 🦾 ⚙️ 🔋',
          options: ['🤖 🦾 ⚙️ 🔋', '🤖 ⚙️ 🦾 🔋', '🦾 🤖 ⚙️ 🔋'],
          correctIndex: 0,
          studyPrompt: 'Remember the core helpers!',
          hint: 'Robot first, arm second — say the order out loud!',
          rewardLabel: 'Memory Key',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Final Word Trial: which word matches the picture?',
          visual: '🏆',
          options: ['CHAMPION', 'CHIMNEY', 'CHIPMUNK'],
          correctIndex: 0,
          hint: 'The winner of everything is the...',
          rewardLabel: 'Champion Key',
        ),
      ],
    ),
  ];
}
