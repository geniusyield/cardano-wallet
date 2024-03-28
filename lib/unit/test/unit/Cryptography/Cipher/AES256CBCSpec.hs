{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RecordWildCards #-}

module Cryptography.Cipher.AES256CBCSpec
    ( spec
    ) where

import Prelude

import Cryptography.Cipher.AES256CBC
    ( CipherError (..)
    , CipherMode (..)
    , decrypt
    , encrypt
    , paddingPKCS7
    , unpaddingPKCS7
    )
import Data.ByteString
    ( ByteString
    )
import Test.Hspec
    ( Spec
    , describe
    , it
    )
import Test.QuickCheck
    ( Arbitrary (..)
    , chooseInt
    , oneof
    , property
    , suchThat
    , vectorOf
    , (===)
    )

import qualified Data.ByteString as BS

spec :: Spec
spec = do
    describe "Padding/unpadding roundtrip" $
        it "unpad . pad $ payload == payload" $ property $ \payload -> do
            let toPayload Nothing = Payload BS.empty
                toPayload (Just bs) = Payload bs
            toPayload ( (paddingPKCS7 $ unPayload payload) >>= unpaddingPKCS7 ) === payload
    describe "Padding produces always payload that is multiple of 16 bytes" $
        it "(pad payload) % 16 == 0" $ property $ \payload -> do
            let toPayloadLen Nothing = 0
                toPayloadLen (Just bs) = BS.length bs
            (toPayloadLen ( (paddingPKCS7 $ unPayload payload)) ) `mod` 16 === 0
    describe "encrypt/decrypt roundtrip with padding" $
        it "decrypt . encrypt $ payload == payload" $ property $
        \(CipherPaddingSetup payload' key' iv') -> do
            let toPayload (Left EmptyPayload) = Right BS.empty
                toPayload res = res
            toPayload (encrypt WithPadding key' iv' payload' >>=
                decrypt WithPadding key' iv') === Right payload'

    describe "encrypt/decrypt roundtrip without padding" $
        it "decrypt . encrypt $ payload == payload" $ property $
        \(CipherRawSetup payload' key' iv') -> do
            let toPayload (Left EmptyPayload) = Right BS.empty
                toPayload res = res
            toPayload (encrypt WithoutPadding key' iv' payload' >>=
                decrypt WithoutPadding key' iv') === Right payload'

    describe "encrypt with incorrect block size" $
        it "encrypt payload == error" $ property $
        \(CipherWrongSetup payload' key' iv') -> do
            encrypt WithoutPadding key' iv' payload' ===
                Left WrongPayloadSize

    describe "decrypt with incorrect block size" $
        it "decrypt payload == error" $ property $
        \(CipherWrongSetup payload' key' iv') -> do
            decrypt WithoutPadding key' iv' payload' ===
                Left WrongPayloadSize

newtype Payload = Payload
    { unPayload :: ByteString } deriving (Eq, Show)

data CipherPaddingSetup = CipherPaddingSetup
    { payloadPad :: ByteString
    , keyPad :: ByteString
    , ivPad :: ByteString
    } deriving (Eq, Show)

data CipherRawSetup = CipherRawSetup
    { payloadRaw :: ByteString
    , keyRaw :: ByteString
    , ivRaw :: ByteString
    } deriving (Eq, Show)

data CipherWrongSetup = CipherWrongSetup
    { payloadWrong :: ByteString
    , keyWrong :: ByteString
    , ivWrong :: ByteString
    } deriving (Eq, Show)

instance Arbitrary Payload where
    arbitrary = do
        payloadLength <- chooseInt (1, 512)
        oneof [ Payload . BS.pack <$> vectorOf payloadLength arbitrary
              , pure $ Payload BS.empty
              ]

instance Arbitrary CipherPaddingSetup where
    arbitrary = do
        Payload payload' <- arbitrary
        key' <- BS.pack <$> vectorOf 32 arbitrary
        iv' <- BS.pack <$> vectorOf 16 arbitrary
        pure $ CipherPaddingSetup payload' key' iv'

instance Arbitrary CipherRawSetup where
    arbitrary = do
        lenMult <- chooseInt (1,256)
        payload' <- BS.pack <$> vectorOf (lenMult * 16) arbitrary
        key' <- BS.pack <$> vectorOf 32 arbitrary
        iv' <- BS.pack <$> vectorOf 16 arbitrary
        pure $ CipherRawSetup payload' key' iv'

instance Arbitrary CipherWrongSetup where
    arbitrary = do
        len <- chooseInt (1,512) `suchThat` (\p -> p `mod` 16 /= 0)
        payload' <- BS.pack <$> vectorOf len arbitrary
        key' <- BS.pack <$> vectorOf 32 arbitrary
        iv' <- BS.pack <$> vectorOf 16 arbitrary
        pure $ CipherWrongSetup payload' key' iv'
