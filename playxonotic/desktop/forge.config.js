module.exports = {
  packagerConfig: {
    name: 'PlayXonotic',
    executableName: 'playxonotic',
    icon: './icons/icon',
    asar: true,
    extraResource: ['./game'],
  },
  makers: [
    {
      name: '@electron-forge/maker-zip',
      platforms: ['darwin', 'linux', 'win32'],
    },
    {
      name: '@electron-forge/maker-deb',
      platforms: ['linux'],
      config: {
        options: {
          bin: 'playxonotic',
          maintainer: 'Barramee Kottanawadee',
          homepage: 'https://playxonotic.com',
        },
      },
    },
    {
      name: '@electron-forge/maker-dmg',
      platforms: ['darwin'],
      config: {
        format: 'ULFO',
      },
    },
    {
      name: '@electron-forge/maker-squirrel',
      platforms: ['win32'],
      config: {
        options: {
          name: 'playxonotic-desktop',
        },
      },
    },
  ],
};
