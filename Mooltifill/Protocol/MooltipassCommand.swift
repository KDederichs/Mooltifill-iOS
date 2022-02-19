//
//  MoolticuteCommands.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.02.22.
//

enum MooltipassCommand: UInt16 {
    //Mini
    case EXPORT_FLASH_START = 0x8A
    case EXPORT_FLASH = 0x8B
    case EXPORT_FLASH_END = 0x8C
    case IMPORT_FLASH_BEGIN = 0x8D
    case IMPORT_FLASH = 0x8E
    case IMPORT_FLASH_END = 0x8F
    case EXPORT_EEPROM_START = 0x90
    case EXPORT_EEPROM = 0x91
    case EXPORT_EEPROM_END = 0x92
    case IMPORT_EEPROM_BEGIN = 0x93
    case IMPORT_EEPROM = 0x94
    case IMPORT_EEPROM_END = 0x95
    case ERASE_EEPROM = 0x96
    case ERASE_FLASH = 0x97
    case ERASE_SMC = 0x98
    case DRAW_BITMAP = 0x99
    case SET_FONT = 0x9A
    case USB_KEYBOARD_PRESS = 0x9B
    case STACK_FREE = 0x9C
    case CLONE_SMARTCARD = 0x9D
    case DEBUG_MINI = 0xA0
    case PING_MINI = 0xA1
    case VERSION = 0xA2
    case CONTEXT = 0xA3
    case GET_LOGIN = 0xA4
    case GET_PASSWORD = 0xA5
    case SET_LOGIN = 0xA6
    case SET_PASSWORD = 0xA7
    case CHECK_PASSWORD = 0xA8
    case ADD_CONTEXT = 0xA9
    case SET_BOOTLOADER_PWD = 0xAA
    case JUMP_TO_BOOTLOADER = 0xAB
    case GET_RANDOM_NUMBER_MINI = 0xAC
    case START_MEMORYMGMT_MINI = 0xAD
    case GET_RANDOM_NUMBER_BLE = 0x0008
    case START_MEMORYMGMT_BLE = 0x0009
    case IMPORT_MEDIA_START = 0xAE
    case IMPORT_MEDIA = 0xAF
    case IMPORT_MEDIA_END = 0xB0
    case SET_MOOLTIPASS_PARM = 0xB1
    case GET_MOOLTIPASS_PARM = 0xB2
    case RESET_CARD_MINI = 0xB3
    case RESET_CARD_BLE = 0x000E
    case READ_CARD_LOGIN = 0xB4
    case READ_CARD_PASS = 0xB5
    case SET_CARD_LOGIN = 0xB6
    case SET_CARD_PASS = 0xB7
    case ADD_UNKNOWN_CARD = 0xB8
    case MOOLTIPASS_STATUS_MINI = 0xB9
    case MOOLTIPASS_STATUS_BLE = 0x0011
    case FUNCTIONAL_TEST_RES = 0xBA
    case SET_DATE_MINI = 0xBB
    case SET_DATE_BLE = 0x0004
    case SET_UID = 0xBC
    case GET_UID = 0xBD
    case SET_DATA_SERVICE = 0xBE
    case ADD_DATA_SERVICE = 0xBF
    case WRITE_32B_IN_DN = 0xC0
    case READ_32B_IN_DN = 0xC1
    case GET_CUR_CARD_CPZ_MINI = 0xC2
    case CANCEL_USER_REQUEST_MINI = 0xC3
    case PLEASE_RETRY_MINI = 0xC4
    case READ_FLASH_NODE_MINI = 0xC5
    case GET_CUR_CARD_CPZ_BLE = 0x000B
    case CANCEL_USER_REQUEST_BLE = 0x0005
    case PLEASE_RETRY_BLE = 0x0002
    case READ_FLASH_NODE_BLE = 0x0102
    case WRITE_FLASH_NODE = 0xC6
    case GET_FAVORITE = 0xC7
    case SET_FAVORITE = 0xC8
    case GET_STARTING_PARENT_MINI = 0xC9
    case GET_STARTING_PARENT_BLE = 0x0100
    case SET_STARTING_PARENT = 0xCA
    case GET_CTRVALUE_MINI = 0xCB
    case GET_CTRVALUE_BLE = 0x0109
    case SET_CTRVALUE = 0xCC
    case ADD_CARD_CPZ_CTR = 0xCD
    case GET_CARD_CPZ_CTR = 0xCE
    case CARD_CPZ_CTR_PACKET = 0xCF
    case GET_30_FREE_SLOTS = 0xD0
    case GET_DN_START_PARENT = 0xD1
    case SET_DN_START_PARENT = 0xD2
    case END_MEMORYMGMT_MINI = 0xD3
    case END_MEMORYMGMT_BLE = 0x0101
    case SET_USER_CHANGE_NB = 0xD4
    case GET_DESCRIPTION = 0xD5
    case GET_USER_CHANGE_NB_MINI = 0xD6
    case GET_USER_CHANGE_NB_BLE = 0x000A
    case GET_AVAILABLE_USERS_MINI = 0xD7
    case SET_DESCRIPTION = 0xD8
    case LOCK_DEVICE_MINI = 0xD9
    case LOCK_DEVICE_BLE = 0x0010
    case GET_SERIAL = 0xDA

    //Mini BLE
    case DEBUG_BLE = 0x8000
    case PING_BLE = 0x0001
    case GET_PLAT_INFO_BLE = 0x0003
    case STORE_CREDENTIAL_BLE = 0x0006
    case GET_CREDENTIAL_BLE = 0x0007
    case GET_DEVICE_SETTINGS_BLE = 0x000C
    case SET_DEVICE_SETTINGS_BLE = 0x000D
    case GET_AVAILABLE_USERS_BLE = 0x000F
    case CHECK_CREDENTIAL_BLE = 0x0012
    case GET_USER_SETTINGS_BLE = 0x0013
    case GET_USER_CATEGORIES_BLE = 0x0014
    case SET_USER_CATEGORIES_BLE = 0x0015
    case GET_DEVICE_SN = 0x0038
    case CMD_DBG_OPEN_DISP_BUFFER_BLE = 0x8001
    case CMD_DBG_SEND_TO_DISP_BUFFER_BLE = 0x8002
    case CMD_DBG_CLOSE_DISP_BUFFER_BLE = 0x8003
    case CMD_DBG_ERASE_DATA_FLASH_BLE = 0x8004
    case CMD_DBG_IS_DATA_FLASH_READY_BLE = 0x8005
    case CMD_DBG_DATAFLASH_WRITE_256B_BLE = 0x8006
    case CMD_DBG_REBOOT_TO_BOOTLOADER_BLE = 0x8007
    case CMD_DBG_GET_ACC_32_SAMPLES_BLE = 0x8008
    case CMD_DBG_FLASH_AUX_MCU_BLE = 0x8009
    case CMD_DBG_GET_PLAT_INFO_BLE = 0x800A
    case CMD_DBG_REINDEX_BUNDLE_BLE = 0x800B
}
