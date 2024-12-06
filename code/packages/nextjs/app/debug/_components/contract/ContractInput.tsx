"use client";

import { Dispatch, SetStateAction } from "react";
import { Tuple } from "./Tuple";
import { TupleArray } from "./TupleArray";
import { AbiParameter } from "abitype";
import {
  AddressInput,
  Bytes32Input,
  BytesInput,
  InputBase,
  IntegerInput,
  IntegerVariant,
} from "~~/components/scaffold-eth";
import { AbiParameterTuple } from "~~/utils/scaffold-eth/contract";

type ContractInputProps = {
  setForm: Dispatch<SetStateAction<Record<string, any>>>;
  form: Record<string, any> | undefined;
  stateObjectKey: string;
  paramType: AbiParameter;
};

  const customInputProps = {
    '_monthlyAverageProfit': 'Please input monthly profit (uint256)',
    'account': 'Please input the account address (address)',
    '': 'Please input the account address (address)',
    'amount': 'Please input the token amount (uint256)',
    'value': 'Please input the token amount (uint256)',
    'to': 'Please input the receiver address (address)',
    'withdrawAddress': 'Please input the withdraw address (address)',
    'orderAmount': 'Please input the order amount (uint256)',
    'referrer': 'Please input the referrer\'s address (address)'
  }

/**
 * Generic Input component to handle input's based on their function param type
 */
export const ContractInput = ({ setForm, form, stateObjectKey, paramType }: ContractInputProps) => {
  const inputProps = {
    name: stateObjectKey,
    value: form?.[stateObjectKey],
    placeholder: customInputProps[paramType.name] || paramType.name,
    // placeholder: paramType.name ? `${paramType.type} ${paramType.name}` : paramType.type,
    onChange: (value: any) => {
      setForm(form => ({ ...form, [stateObjectKey]: value }));
    },
  };

  const renderInput = () => {
    switch (paramType.type) {
      case "address":
        return <AddressInput {...inputProps} />;
      case "bytes32":
        return <Bytes32Input {...inputProps} />;
      case "bytes":
        return <BytesInput {...inputProps} />;
      case "string":
        return <InputBase {...inputProps} />;
      case "tuple":
        return (
          <Tuple
            setParentForm={setForm}
            parentForm={form}
            abiTupleParameter={paramType as AbiParameterTuple}
            parentStateObjectKey={stateObjectKey}
          />
        );
      default:
        // Handling 'int' types and 'tuple[]' types
        if (paramType.type.includes("int") && !paramType.type.includes("[")) {
          return <IntegerInput {...inputProps} variant={paramType.type as IntegerVariant} />;
        } else if (paramType.type.startsWith("tuple[")) {
          return (
            <TupleArray
              setParentForm={setForm}
              parentForm={form}
              abiTupleParameter={paramType as AbiParameterTuple}
              parentStateObjectKey={stateObjectKey}
            />
          );
        } else {
          return <InputBase {...inputProps} />;
        }
    }
  };

  const displayNameMap = {
    '_monthlyAverageProfit': 'Average monthly profit',
    'account': 'Account Address',
    'orderAmount': 'Order Amount',
    'referrer': 'Referrer Address',
    'to': 'Receiver Address',
    'amount': 'Token Amount',
    'from': 'Spender Address',
    'value': 'Token Amount',
    'withdrawAddress': 'Withdraw Address',
    '': 'Account Address',
    null: 'Account Address'
  };
  if (!paramType.name in displayNameMap){
    displayNameMap[paramType.name] = paramType.name+ '!!!'
    console.log('param', paramType.name)
  }
  // displayNameMap[paramType.name]



  return (
    <div className="flex flex-col gap-1.5 w-full">
      <div className="flex items-center ml-2">
        {paramType.name && <span className="text-xs font-medium mr-2 leading-none">{displayNameMap[paramType.name] || paramType.name}</span>}
        <span className="block text-xs font-extralight leading-none">{paramType.type}</span>
      </div>
      {renderInput(customInputProps[paramType.name])}
    </div>
  );
};
