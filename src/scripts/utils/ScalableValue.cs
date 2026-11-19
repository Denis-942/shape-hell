using System;

namespace Utils
{
    public class ScalableValue<TBase, TScalar>
    {
        public TBase Base { get; set; }
        public TScalar Scalar { get; set; }
        public Func<TBase, TScalar, TBase> ScalingFunc { get; private set; }
        public TBase Scaled
        {
            get
            {
                return ScalingFunc(Base, Scalar);
            }
        }

        public ScalableValue(TBase baseValue, TScalar scalarValue, Func<TBase, TScalar, TBase> scalingFunc)
        {
            Base = baseValue;
            Scalar = scalarValue;
            ScalingFunc = scalingFunc ?? throw new ArgumentNullException(nameof(scalingFunc));
        }

    }
    public class ScalableValue
    {
        public static ScalableValue<TBase, TScalar> Create<TBase, TScalar>(
            TBase baseValue,
            TScalar scalarValue,
            Func<TBase, TScalar, TBase> scalingFunc)
        {
            return new ScalableValue<TBase, TScalar>(baseValue, scalarValue, scalingFunc);
        }
    }
}
